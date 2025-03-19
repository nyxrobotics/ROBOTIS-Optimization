#ifndef SCILAB_OPTIMIZATION_H
#define SCILAB_OPTIMIZATION_H
#include <ros/console.h>
#include <string>
#include <vector>
#include <scilab/api_scilab.h>
#include <scilab/call_scilab.h>
namespace robotis_framework
{
class ScilabOptimization
{
public:
  ScilabOptimization();
  ~ScilabOptimization();

  static void initialize();
  static void terminate();

  static void solveRiccatiEquation(double*& K, int* row_K, int* col_K, double*& S, int* row_S, int* col_S, double*& E,
                                   double*& E_img, int* row_E, int* col_E, double* A, int row_A, int col_A, double* B,
                                   int row_B, int col_B, double* Q, int row_Q, int col_Q, double* R, int row_R,
                                   int col_R);
};
}  // namespace robotis_framework
#endif  // SCILAB_OPTIMIZATION_H
