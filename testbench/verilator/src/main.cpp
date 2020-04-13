#include <iostream>
#include <verilated.h>
#include <Vtiny_rv.h>
#include "testbench.h"

#define DO_TRACE 1

void load_memory(FILE *fd, uint32_t* buffer) {
  size_t size = fread(buffer, 4, 65535, fd);
  printf("Loaded %d words\n", size);
}


int main(int argc, char** argv) {
  Verilated::commandArgs(argc, argv);
  auto *tb = new TESTBENCH<Vtiny_rv>();

  FILE *f;
  if (argc > 1 && (f = fopen(argv[1], "rb"))!= nullptr) {
    load_memory(f, tb->m_core->tiny_rv__DOT__fetch__DOT__imem);
    fclose(f);
  } else {
    printf("WARN: No file loaded!\n");
  }

#if DO_TRACE
  tb->opentrace("trace.vcd");
#endif

  tb->reset();

  for (int i = 0; i < 100 * 100000; ++i) {
    tb->tick();
    if (tb->m_core->tiny_rv__DOT__rr_opcode == 0b1110011 && tb->m_core->tiny_rv__DOT__rr_funct3 == 0) {
        uint16_t csr = tb->m_core->tiny_rv__DOT__exec__DOT__rr_csr;
        uint32_t GP = tb->m_core->tiny_rv__DOT__dprf__DOT__registers[3];
        if (tb->m_core->tiny_rv__DOT__exec__DOT__exec_rd == 3) {
            GP = tb->m_core->tiny_rv__DOT__exec__DOT__exec_rd_val;
        }
//        printf("SYSTEM: CSR: %X: GP(r3) = 0x%08X @ 0x%08X\n", csr, GP, tb->m_core->tiny_rv__DOT__rr_pc);
        if (csr == 0x0) {
            if (GP >> 1 != 0) {
                printf("ECALL EXIT on test case %d, status = %d", GP >> 1, GP & 0x1);
                printf("\nFAIL\n");
            } else {
                printf("PASS\n");
            }
            break;
        }
    }
  }

#if DO_TRACE
  tb->close();
#endif

  return 0;
}
