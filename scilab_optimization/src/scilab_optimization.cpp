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
extern "C" void* pvApiCtx;

namespace robotis_framework
{
ScilabOptimization::ScilabOptimization()
{
}

ScilabOptimization::~ScilabOptimization()
{
}

void ScilabOptimization::initialize()
{
#ifdef _MSC_VER
  if (StartScilab(NULL, NULL, NULL) == FALSE)
#else
  if (StartScilab(const_cast<char*>(SCILIB_PATH), NULL, NULL) == FALSE)
#endif
  {
    ROS_WARN("Error while calling StartScilab");
  }
}

void ScilabOptimization::terminate()
{
  if (TerminateScilab(NULL) == FALSE)
  {
    fprintf(stderr, "Error while calling TerminateScilab\n");
    return;
  }
}

void ScilabOptimization::solveRiccatiEquation(double*& K, int* row_K, int* col_K, double*& S, int* row_S, int* col_S,
                                              double*& E, double*& E_img, int* row_E, int* col_E, double* A, int row_A,
                                              int col_A, double* B, int row_B, int col_B, double* Q, int row_Q,
                                              int col_Q, double* R, int row_R, int col_R)
{
  SciErr sciErr;

  char var_A[] = "A";
  char var_B[] = "B";
  char var_Q[] = "Q";
  char var_R[] = "R";
  char var_K[] = "K";
  char var_S[] = "S";
  char var_E[] = "E";

  // Set input matrices
  sciErr = createNamedMatrixOfDouble(pvApiCtx, var_A, row_A, col_A, A);
  if (sciErr.iErr)
    printError(&sciErr, 0);

  sciErr = createNamedMatrixOfDouble(pvApiCtx, var_B, row_B, col_B, B);
  if (sciErr.iErr)
    printError(&sciErr, 0);

  sciErr = createNamedMatrixOfDouble(pvApiCtx, var_Q, row_Q, col_Q, Q);
  if (sciErr.iErr)
    printError(&sciErr, 0);

  sciErr = createNamedMatrixOfDouble(pvApiCtx, var_R, row_R, col_R, R);
  if (sciErr.iErr)
    printError(&sciErr, 0);

  // Execute Scilab commands
  SendScilabJob(const_cast<char*>("b = B / R * B';"));
  SendScilabJob(const_cast<char*>("S = riccati(A,b,Q,'d','eigen');"));
  SendScilabJob(const_cast<char*>("K = inv(B'*S*B + R)*(B'*S*A);"));
  SendScilabJob(const_cast<char*>("E = spec(A - B*K);"));

  int row = 0, col = 0;

  // Get matrix K
  sciErr = readNamedMatrixOfDouble(pvApiCtx, var_K, &row, &col, NULL);
  K = (double*)malloc(sizeof(double) * row * col);
  sciErr = readNamedMatrixOfDouble(pvApiCtx, var_K, &row, &col, K);
  *row_K = row;
  *col_K = col;

  // Get matrix S
  sciErr = readNamedMatrixOfDouble(pvApiCtx, var_S, &row, &col, NULL);
  S = (double*)malloc(sizeof(double) * row * col);
  sciErr = readNamedMatrixOfDouble(pvApiCtx, var_S, &row, &col, S);
  *row_S = row;
  *col_S = col;

  // Get eigenvalues E (complex)
  sciErr = readNamedMatrixOfDouble(pvApiCtx, var_E, &row, &col, NULL);
  E = (double*)malloc(sizeof(double) * row * col);
  E_img = (double*)malloc(sizeof(double) * row * col);
  sciErr = readNamedComplexMatrixOfDouble(pvApiCtx, var_E, &row, &col, E, E_img);
  *row_E = row;
  *col_E = col;
}

}  // namespace robotis_framework
