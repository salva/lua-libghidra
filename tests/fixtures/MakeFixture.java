// MIT Copyright 2026 Salvador Fandiño.
// Development-only Ghidra generator. Byte-array memory deliberately has no
// FileBytes: exercises the documented external-executable project load branch.
import ghidra.app.script.GhidraScript;
import ghidra.program.model.address.Address;
import ghidra.program.model.listing.CodeUnit;
import ghidra.program.model.symbol.SourceType;
import ghidra.program.model.data.DWordDataType;
import java.nio.file.*;
public class MakeFixture extends GhidraScript {
  public void run() throws Exception {
    currentProgram = new ghidra.program.database.ProgramDB("authored", getLanguage(new ghidra.program.model.lang.LanguageID("x86:LE:64:default")), getLanguage(new ghidra.program.model.lang.LanguageID("x86:LE:64:default")).getCompilerSpecByID(new ghidra.program.model.lang.CompilerSpecID("gcc")), this);
    int tx = currentProgram.startTransaction("authored fixture");
    byte[] text = Files.readAllBytes(Path.of(getScriptArgs()[0]));
    Address start = toAddr(0x401020);
    var block = currentProgram.getMemory().createInitializedBlock("authored_text", start, text.length, (byte)0, monitor, false);
    block.setExecute(true); block.setRead(true); block.setWrite(false);
    currentProgram.getMemory().setBytes(start, text);
    disassemble(toAddr(0x401106)); disassemble(toAddr(0x40111f));
    createFunction(toAddr(0x401106), "native_smoke"); createFunction(toAddr(0x40111f), "main");
    currentProgram.getListing().setComment(start, CodeUnit.EOL_COMMENT, "authored fixture arithmetic");
    disassemble(toAddr(0x40113c)); createFunction(toAddr(0x40113c), "read_authored_value");
    currentProgram.getMemory().createInitializedBlock("authored_data", toAddr(0x404010), 4, (byte)0, monitor, false);
    currentProgram.getMemory().setInt(toAddr(0x404010), 23);
    createData(toAddr(0x404010), new DWordDataType());
    analyzeAll(currentProgram);
    currentProgram.endTransaction(tx, true);
    state.getProject().getProjectData().getRootFolder().createFile("authored", currentProgram, monitor);
    println("AUTHORED_PROJECT language=" + currentProgram.getLanguageID() + " entry=" + start);
  }
}
