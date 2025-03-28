/*******************************************************************************
 * Copyright (c) 2016, ROBOTIS CO., LTD.
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * * Redistributions of source code must retain the above copyright notice, this
 *   list of conditions and the following disclaimer.
 *
 * * Redistributions in binary form must reproduce the above copyright notice,
 *   this list of conditions and the following disclaimer in the documentation
 *   and/or other materials provided with the distribution.
 *
 * * Neither the name of ROBOTIS nor the names of its
 *   contributors may be used to endorse or promote products derived from
 *   this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *******************************************************************************/

/*
 * scilab_optimization.cpp
 *
 *  Created on: December 1, 2016
 *      Author: sch
 */

#include "scilab_optimization/scilab_optimization.h"
#include <fstream>
#include <cstdlib>
#include <vector>
#include <string>
#include <cstring>
#include <sys/stat.h>
#include <unistd.h>
#include <iostream>

namespace robotis_framework
{
ScilabOptimization::ScilabOptimization()
{
}
ScilabOptimization::~ScilabOptimization()
{
}

void ScilabOptimization::printSceContent(const std::string& path)
{
  std::ifstream in(path);
  if (in.is_open())
  {
    std::cout << "\n--- SCE FILE CONTENT: " << path << " ---\n";
    std::string line;
    while (std::getline(in, line))
      std::cout << line << "\n";
    std::cout << "--- END SCE ---\n";
  }
}

void ScilabOptimization::printCsvContent(const std::string& label, const std::string& path)
{
  std::ifstream in(path);
  if (in.is_open())
  {
    std::cout << "\n" << label << " (CSV: " << path << "):\n";
    std::string line;
    while (std::getline(in, line))
      std::cout << line << "\n";
  }
}

bool ScilabOptimization::solveRiccatiEquation(double* K, int* row_K, int* col_K, double* S, int* row_S, int* col_S,
                                              double* E, double* E_img, int* row_E, int* col_E, double* A, int row_A,
                                              int col_A, double* B, int row_B, int col_B, double* Q, int row_Q,
                                              int col_Q, double* R, int row_R, int col_R)
{
  /*
  This function calculates the optimal gain matrix K
  such that the state-feedback law  u[n] = -Kx[n]  minimizes the
  cost function

        J = Sum {x'Qx + u'Ru}

  subject to the state dynamics   x[n+1] = A*x[n] + B*u[n].

  Also calculated are the
  Riccati equation solution S and the closed-loop eigenvalues E:
                              -1
   A'SA - S - (A'SB+N)(R+B'SB) (B'SA+N') + Q = 0,   E = EIG(A-B*K).
*/

  std::string ram_path = "/dev/shm/scilab_tmp/";
  mkdir(ram_path.c_str(), 0777);

  std::string sce_path = ram_path + "solve_riccati.sce";
  std::ofstream file(sce_path);
  if (!file.is_open())
    return false;

  /****** CALCULATION ******/
  auto writeMatrix = [&](const std::string& name, double* data, int rows, int cols) {
    file << name << " = [";
    for (int i = 0; i < rows * cols; ++i)
      file << data[i] << (i + 1 < rows * cols ? "," : "];\n");
    file << name << " = matrix(" << name << ", " << rows << ", " << cols << ");\n";
  };

  writeMatrix("A", A, row_A, col_A);
  writeMatrix("B", B, row_B, col_B);
  writeMatrix("Q", Q, row_Q, col_Q);
  writeMatrix("R", R, row_R, col_R);

  file << "b = B / R * B';\n";
  file << "S = riccati(A, b, Q, 'd', 'eigen');\n";
  file << "K = inv(B'*S*B + R) * (B'*S*A);\n";
  file << "E = spec(A - B*K);\n";

  file << "csvWrite(K, '" << ram_path << "K.csv');\n";  // Read Matrix K
  file << "csvWrite(S, '" << ram_path << "S.csv');\n";  // Read Matrix S
  file << "csvWrite(E, '" << ram_path << "E.csv');\n";  // Read Matrix E
  file << "exit;\n";
  file.close();

  printSceContent(sce_path);

  std::string command = "scilab-cli -nwni -nogui -f " + sce_path;
  int result = std::system(command.c_str());
  if (result != 0)
  {
    unlink((ram_path + "solve_riccati.sce").c_str());
    return false;
  }

  auto loadCSV = [](const std::string& filename, std::vector<double>& out, int* row, int* col) -> bool {
    std::ifstream in(filename);
    if (!in.is_open())
      return false;
    std::string line;
    int rows = 0, cols = -1;
    while (std::getline(in, line))
    {
      std::istringstream iss(line);
      std::string val;
      int current_cols = 0;
      while (std::getline(iss, val, ','))
      {
        out.push_back(std::stod(val));
        ++current_cols;
      }
      if (cols == -1)
        cols = current_cols;
      else if (cols != current_cols)
        return false;
      ++rows;
    }
    *row = rows;
    *col = cols;
    return true;
  };

  std::vector<double> K_v, S_v, E_v;
  std::string k_path = ram_path + "K.csv";
  std::string s_path = ram_path + "S.csv";
  std::string e_path = ram_path + "E.csv";

  if (!loadCSV(k_path, K_v, row_K, col_K) || !loadCSV(s_path, S_v, row_S, col_S) ||
      !loadCSV(e_path, E_v, row_E, col_E) || *row_K <= 0 || *col_K <= 0 || *row_S <= 0 || *col_S <= 0 || K_v.empty() ||
      S_v.empty())
  {
    std::cerr << "[ERROR] Failed to load matrices or invalid dimensions\n";
    unlink(sce_path.c_str());
    unlink(k_path.c_str());
    unlink(s_path.c_str());
    unlink(e_path.c_str());
    return false;
  }

  printCsvContent("K", k_path);
  printCsvContent("S", s_path);
  printCsvContent("E", e_path);

  std::memcpy(K, K_v.data(), sizeof(double) * K_v.size());
  std::memcpy(S, S_v.data(), sizeof(double) * S_v.size());
  std::memcpy(E, E_v.data(), sizeof(double) * E_v.size());
  std::memset(E_img, 0, sizeof(double) * (*row_E) * (*col_E));

  unlink(sce_path.c_str());
  unlink(k_path.c_str());
  unlink(s_path.c_str());
  unlink(e_path.c_str());

  return true;
}

}  // namespace robotis_framework
