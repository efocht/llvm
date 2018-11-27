//===-- VEMCExpr.cpp - VE specific MC expression classes ------------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file contains the implementation of the assembly expression modifiers
// accepted by the VE architecture (e.g. "%hi", "%lo", ...).
//
//===----------------------------------------------------------------------===//

#include "VEMCExpr.h"
#include "llvm/MC/MCAssembler.h"
#include "llvm/MC/MCContext.h"
#include "llvm/MC/MCObjectStreamer.h"
#include "llvm/MC/MCSymbolELF.h"
#include "llvm/Object/ELF.h"

using namespace llvm;

#define DEBUG_TYPE "vemcexpr"

const VEMCExpr*
VEMCExpr::create(VariantKind Kind, const MCExpr *Expr,
                      MCContext &Ctx) {
    return new (Ctx) VEMCExpr(Kind, Expr);
}

void VEMCExpr::printImpl(raw_ostream &OS, const MCAsmInfo *MAI) const {

  bool closeParen = printVariantKind(OS, Kind);

  const MCExpr *Expr = getSubExpr();
  Expr->print(OS, MAI);

  if (closeParen)
    OS << ')';
  printVariantKindSuffix(OS, Kind);
}

bool VEMCExpr::printVariantKind(raw_ostream &OS, VariantKind Kind)
{
  bool closeParen = true;
  switch (Kind) {
  case VK_VE_None:          closeParen = false; break;
  case VK_VE_R_DISP32:      OS << "%r_disp32("; break;
  case VK_VE_HI32:          return false; // OS << "%hi(";  break;
  case VK_VE_LO32:          return false; // OS << "%lo(";  break;
  case VK_VE_PC_HI32:       return false; // OS << "%pc_hi("; break;
  case VK_VE_PC_LO32:       return false; // OS << "%pc_lo("; break;
  case VK_VE_GOT_HI32:      return false; // OS << "%got_hi("; break;
  case VK_VE_GOT_LO32:      return false; // OS << "%got_lo("; break;
  case VK_VE_GOTOFF_HI32:   return false; // OS << "%gotoff_hi("; break;
  case VK_VE_GOTOFF_LO32:   return false; // OS << "%gotoff_lo("; break;
  case VK_VE_PLT_HI32:      return false; // OS << "%plt_hi("; break;
  case VK_VE_PLT_LO32:      return false; // OS << "%plt_lo("; break;
  case VK_VE_TLS_GD_HI32:   return false; // OS << "%tls_gd_hi(";   break;
  case VK_VE_TLS_GD_LO32:   return false; // OS << "%tls_gd_lo(";   break;
  case VK_VE_TPOFF_HI32:    return false; // OS << "%tpoff_hi(";    break;
  case VK_VE_TPOFF_LO32:    return false; // OS << "%tpoff_lo(";   break;
  }
  return closeParen;
}

void VEMCExpr::printVariantKindSuffix(raw_ostream &OS, VariantKind Kind)
{
  switch (Kind) {
  case VK_VE_None:          break;
  case VK_VE_R_DISP32:      break;
  case VK_VE_HI32:          OS << "@hi";  break;
  case VK_VE_LO32:          OS << "@lo";  break;
  case VK_VE_PC_HI32:       OS << "@pc_hi"; break;
  case VK_VE_PC_LO32:       OS << "@pc_lo"; break;
  case VK_VE_GOT_HI32:      OS << "@got_hi"; break;
  case VK_VE_GOT_LO32:      OS << "@got_lo"; break;
  case VK_VE_GOTOFF_HI32:   OS << "@gotoff_hi"; break;
  case VK_VE_GOTOFF_LO32:   OS << "@gotoff_lo"; break;
  case VK_VE_PLT_HI32:      OS << "@plt_hi"; break;
  case VK_VE_PLT_LO32:      OS << "@plt_lo"; break;
  case VK_VE_TLS_GD_HI32:   OS << "@tls_gd_hi"; break;
  case VK_VE_TLS_GD_LO32:   OS << "@tls_gd_lo"; break;
  case VK_VE_TPOFF_HI32:    OS << "@tpoff_hi"; break;
  case VK_VE_TPOFF_LO32:    OS << "@tpoff_lo"; break;
  }
}

VEMCExpr::VariantKind VEMCExpr::parseVariantKind(StringRef name)
{
  return StringSwitch<VEMCExpr::VariantKind>(name)
    .Case("r_disp32",   VK_VE_R_DISP32)
    .Case("hi",         VK_VE_HI32)
    .Case("lo",         VK_VE_LO32)
    .Case("pc_hi",      VK_VE_PC_HI32)
    .Case("pc_lo",      VK_VE_PC_LO32)
    .Case("got_hi",     VK_VE_GOT_HI32)
    .Case("got_lo",     VK_VE_GOT_LO32)
    .Case("gotoff_hi",  VK_VE_GOTOFF_HI32)
    .Case("gotoff_lo",  VK_VE_GOTOFF_LO32)
    .Case("plt_hi",     VK_VE_PLT_HI32)
    .Case("plt_lo",     VK_VE_PLT_LO32)
    .Case("tls_gd_hi",  VK_VE_TLS_GD_HI32)
    .Case("tls_gd_lo",  VK_VE_TLS_GD_LO32)
    .Case("tpoff_hi",   VK_VE_TPOFF_HI32)
    .Case("tpoff_lo",   VK_VE_TPOFF_LO32)
    .Default(VK_VE_None);
}

VE::Fixups VEMCExpr::getFixupKind(VEMCExpr::VariantKind Kind) {
  switch (Kind) {
  default: llvm_unreachable("Unhandled VEMCExpr::VariantKind");
  case VK_VE_HI32:          return VE::fixup_ve_hi32;
  case VK_VE_LO32:          return VE::fixup_ve_lo32;
  case VK_VE_PC_HI32:       return VE::fixup_ve_pc_hi32;
  case VK_VE_PC_LO32:       return VE::fixup_ve_pc_lo32;
  case VK_VE_GOT_HI32:      return VE::fixup_ve_got_hi32;
  case VK_VE_GOT_LO32:      return VE::fixup_ve_got_lo32;
  case VK_VE_GOTOFF_HI32:   return VE::fixup_ve_gotoff_hi32;
  case VK_VE_GOTOFF_LO32:   return VE::fixup_ve_gotoff_lo32;
  case VK_VE_PLT_HI32:      return VE::fixup_ve_plt_hi32;
  case VK_VE_PLT_LO32:      return VE::fixup_ve_plt_lo32;
  case VK_VE_TLS_GD_HI32:   return VE::fixup_ve_tls_gd_hi32;
  case VK_VE_TLS_GD_LO32:   return VE::fixup_ve_tls_gd_lo32;
  case VK_VE_TPOFF_HI32:    return VE::fixup_ve_tpoff_hi32;
  case VK_VE_TPOFF_LO32:    return VE::fixup_ve_tpoff_lo32;
  }
}

bool
VEMCExpr::evaluateAsRelocatableImpl(MCValue &Res,
                                       const MCAsmLayout *Layout,
                                       const MCFixup *Fixup) const {
  return getSubExpr()->evaluateAsRelocatable(Res, Layout, Fixup);
}

static void fixELFSymbolsInTLSFixupsImpl(const MCExpr *Expr, MCAssembler &Asm) {
  switch (Expr->getKind()) {
  case MCExpr::Target:
    llvm_unreachable("Can't handle nested target expr!");
    break;

  case MCExpr::Constant:
    break;

  case MCExpr::Binary: {
    const MCBinaryExpr *BE = cast<MCBinaryExpr>(Expr);
    fixELFSymbolsInTLSFixupsImpl(BE->getLHS(), Asm);
    fixELFSymbolsInTLSFixupsImpl(BE->getRHS(), Asm);
    break;
  }

  case MCExpr::SymbolRef: {
    const MCSymbolRefExpr &SymRef = *cast<MCSymbolRefExpr>(Expr);
    cast<MCSymbolELF>(SymRef.getSymbol()).setType(ELF::STT_TLS);
    break;
  }

  case MCExpr::Unary:
    fixELFSymbolsInTLSFixupsImpl(cast<MCUnaryExpr>(Expr)->getSubExpr(), Asm);
    break;
  }

}

void VEMCExpr::fixELFSymbolsInTLSFixups(MCAssembler &Asm) const {
#if 0
  switch(getKind()) {
  default: return;
  case VK_VE_TLS_GD_CALL:
  case VK_VE_TLS_LDM_CALL: {
    // The corresponding relocations reference __tls_get_addr, as they call it,
    // but this is only implicit; we must explicitly add it to our symbol table
    // to bind it for these uses.
    MCSymbol *Symbol = Asm.getContext().getOrCreateSymbol("__tls_get_addr");
    Asm.registerSymbol(*Symbol);
    auto ELFSymbol = cast<MCSymbolELF>(Symbol);
    if (!ELFSymbol->isBindingSet()) {
      ELFSymbol->setBinding(ELF::STB_GLOBAL);
      ELFSymbol->setExternal(true);
    }
    LLVM_FALLTHROUGH;
  }
  }
#endif
  fixELFSymbolsInTLSFixupsImpl(getSubExpr(), Asm);
}

void VEMCExpr::visitUsedExpr(MCStreamer &Streamer) const {
  Streamer.visitUsedExpr(*getSubExpr());
}
