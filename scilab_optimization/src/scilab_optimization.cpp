#include "scilab_optimization/scilab_optimization.h"
#include <iostream>
#include <scilab/call_scilab.h>
#include <scilab/api_scilab.h>
#include <scilab/api_stack_double.h>
#include <scilab/api_string.h>

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
  sciErr = createNamedMatrixOfDouble(nullptr, var_A, row_A, col_A, A);
  if (sciErr.iErr)
    printError(&sciErr, 0);

  sciErr = createNamedMatrixOfDouble(nullptr, var_B, row_B, col_B, B);
  if (sciErr.iErr)
    printError(&sciErr, 0);

  sciErr = createNamedMatrixOfDouble(nullptr, var_Q, row_Q, col_Q, Q);
  if (sciErr.iErr)
    printError(&sciErr, 0);

  sciErr = createNamedMatrixOfDouble(nullptr, var_R, row_R, col_R, R);
  if (sciErr.iErr)
    printError(&sciErr, 0);

  // Execute Scilab commands
  SendScilabJob(const_cast<char*>("b = B / R * B';"));
  SendScilabJob(const_cast<char*>("S = riccati(A,b,Q,'d','eigen');"));
  SendScilabJob(const_cast<char*>("K = inv(B'*S*B + R)*(B'*S*A);"));
  SendScilabJob(const_cast<char*>("E = spec(A - B*K);"));

  int row = 0, col = 0;

  // Get matrix K
  sciErr = readNamedMatrixOfDouble(nullptr, var_K, &row, &col, NULL);
  K = (double*)malloc(sizeof(double) * row * col);
  sciErr = readNamedMatrixOfDouble(nullptr, var_K, &row, &col, K);
  *row_K = row;
  *col_K = col;

  // Get matrix S
  sciErr = readNamedMatrixOfDouble(nullptr, var_S, &row, &col, NULL);
  S = (double*)malloc(sizeof(double) * row * col);
  sciErr = readNamedMatrixOfDouble(nullptr, var_S, &row, &col, S);
  *row_S = row;
  *col_S = col;

  // Get eigenvalues E (complex)
  sciErr = readNamedMatrixOfDouble(nullptr, var_E, &row, &col, NULL);
  E = (double*)malloc(sizeof(double) * row * col);
  E_img = (double*)malloc(sizeof(double) * row * col);
  sciErr = readNamedComplexMatrixOfDouble(nullptr, var_E, &row, &col, E, E_img);
  *row_E = row;
  *col_E = col;
}

}  // namespace robotis_framework
