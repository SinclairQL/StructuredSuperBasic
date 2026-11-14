import java.nio.file.*;
import smsqmulator.*;
import CPU.MC68000Cpu;
import screens.Screen0;
import drivers.nxfa.NfaDriver;
import drivers.nxfa.SfaDriver;

/** Runs the local SMSQmulator CPU and real SMSQ/E without a GUI window.
 * The NFA drive is confined to the supplied test directory. No user disks mount.
 * Requires an external SMSQmulator source tree and its licensed SMSQ/E ROM.
 */
public class QlRun {
    public static void main(String[] args) throws Exception {
        long timeoutSeconds=Long.parseLong(args.length>2?args[2]:"40");
        Thread watchdog=new Thread(()->{try {Thread.sleep((timeoutSeconds+15)*1000);System.err.println("Emulator watchdog expired");System.exit(3);}catch(Exception e){}});
        watchdog.setDaemon(true);watchdog.start();
        Path dir = Path.of(args[1]).toAbsolutePath();
        inifile.IniFile ini = new inifile.IniFile();
        for(String k:new String[]{"NFA_USE","SFA_USE","WIN_USE","MEM_USE","FLP_USE","NFA1"}) ini.addOption(k,"","");
        for(String k:new String[]{"SCREEN-MODE","TIME-OFFSET","NFA-FILENAME-CHANGE"}) ini.addOption(k,"0","");
        ini.setOptionValue("SCREEN-MODE", "0");
        ini.setOptionValue("SOUND-VOLUME", "0");
        ini.setOptionValue("NFA1", dir.toString() + java.io.File.separator);
        ini.setOptionValue("DISABLE-WIN-DEVICE", "1");
        SMSQmulator.presetOptions(ini,args[0]);
        ini.setOptionValue("DISABLE-WIN-DEVICE","1");
        ini.setOptionValue("DISABLE-FLP-DEVICE","1");
        ini.setOptionValue("DISABLE-SFA-DEVICE","0");
        ini.setOptionValue("NFA_USE","");
        Screen0 screen = new Screen0(512,256,0,null,false,false,0,false,false);
        int ramMiB=Integer.parseInt(System.getProperty("ql.ramMiB","8"));
        MC68000Cpu cpu = new MC68000Cpu(ramMiB*1024*1024,screen,350000);
        TrapDispatcher traps = new TrapDispatcher(null,null,ini) {
            @Override public void dispatchTrap(int t, MC68000Cpu c) {
                if(t==Types.TRAP5 && (c.data_regs[0]==37 || c.data_regs[0]==12)) {
                    c.data_regs[0]=0; c.reg_sr |= 4; return;
                }
                super.dispatchTrap(t,c);
            }
        };
        NfaDriver drive = new NfaDriver(true) {
            @Override public boolean openFile(int d,int c,int o,int n,byte[] f,byte[] u) {
                boolean ok=super.openFile(d,c,o,n,f,u);
                System.out.println("NFA "+n+" "+o+" "+new String(f)+" -> "+cpu.data_regs[0]);return ok;
            }
        };
        drive.setCpu(cpu);
        String[] names = new String[]{dir.toString()+java.io.File.separator,"","","","","","",""};
        drive.setNames(names,ini,false,false);
        traps.register(drive);
        SfaDriver sfa=new SfaDriver(false) {
            @Override public boolean openFile(int d,int c,int o,int n,byte[] f,byte[] u) {
                boolean ok=super.openFile(d,c,o,n,f,u);
                System.out.println("SFA "+n+" "+o+" "+new String(f)+" -> "+cpu.data_regs[0]);return ok;
            }
        };
        sfa.setCpu(cpu);sfa.setNames(names,ini,false,false);traps.register(sfa);
        cpu.setTrapDispatcher(traps);
        if(!SMSQE.loadRom(args[0],cpu) || !SMSQE.checkForValidSMSQE(cpu) || !SMSQE.setupSMSQE(cpu,ini)) throw new Exception("Cannot load SMSQ/E");
        cpu.writeMemoryLong(cpu.getRamSize()+Types.LINKAGE_BOOT_DEVICE,Types.NFADriver+1);
        QL50HzInterrupt interrupts = new QL50HzInterrupt(cpu);
        interrupts.startInterrupts();
        long deadline=System.nanoTime()+timeoutSeconds*1_000_000_000L;
        long nextKey=System.nanoTime()+3_000_000_000L; int keyIndex=0;
        String command=args.length>3?Files.readString(Path.of(args[3])):"\n\nLRUN nfa1_boot\n";
        var failure=new java.util.concurrent.atomic.AtomicReference<Throwable>();
        Thread runner=new Thread(()->{try {cpu.executeContinuous();}catch(Throwable e){failure.set(e);}},"SMSQ/E CPU");
        runner.setDaemon(true);runner.start();
        try {
            while(System.nanoTime()<deadline) {
                if(failure.get()!=null) throw new Exception("Emulator failure",failure.get());
                if(System.nanoTime()>nextKey && keyIndex<command.length()) {
                    char key=command.charAt(keyIndex);
                    if(key==3) {
                        try {
                            Path output=dir.resolve("output_bas");
                            if(Files.exists(output) && !Files.readString(output,java.nio.charset.StandardCharsets.ISO_8859_1).isBlank()) {keyIndex++;nextKey=System.nanoTime()+1_000_000_000L;}
                        } catch(java.io.IOException stillCopying) { /* retry after close */ }
                    } else if(key==2) {
                        Path report=dir.resolve("report");
                        try {
                            if(Files.exists(report) && Files.readString(report,java.nio.charset.StandardCharsets.ISO_8859_1).contains("Code generation completed")) {keyIndex++;nextKey=System.nanoTime()+2_000_000_000L;}
                        } catch(java.io.IOException lockedWhileCompilerWrites) { /* retry after close */ }
                    } else {traps.addToKeyboardQueue(key);keyIndex++;nextKey=System.nanoTime()+150_000_000L;}
                }
                if(Files.exists(dir.resolve("done"))) {
                    try {
                        String done=Files.readString(dir.resolve("done"));
                        if(!done.isBlank() && done.endsWith("\n")) {System.out.println("SMSQ/E completed"); return;}
                    } catch(java.io.IOException stillWriting) { /* wait for close */ }
                }
                Thread.sleep(10);
            }
            var pic=new java.awt.image.BufferedImage(512,256,java.awt.image.BufferedImage.TYPE_INT_RGB);
            screen.setSize(512,256);screen.paint(pic.createGraphics());
            javax.imageio.ImageIO.write(pic,"png",dir.resolve("screen.png").toFile());
            throw new Exception("SMSQ/E timeout, pc="+Integer.toHexString(cpu.pc_reg*2));
        } finally {cpu.endEmulation(false);runner.join(1000);interrupts.stopInterrupts();traps.closeAllFiles(); }
    }
}
