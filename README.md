# scilab_optimization

This package provides a ROS-compatible C++ wrapper to run optimization routines using [Scilab](https://www.scilab.org) via its C API.  
It is particularly suited for solving optimal control problems such as the discrete-time Riccati equation in robotics applications.

---

## Features

- Solves discrete-time Riccati equations with user-defined `A`, `B`, `Q`, `R` matrices
- Exposes optimal gain `K`, Riccati solution `S`, and closed-loop poles `E`
- ROS-compatible and can be used in combination with other ROS packages
- Uses `.sce` script files and CSV-based file I/O to interface with Scilab cleanly
- Stores all intermediate files in RAM (`/dev/shm`) for speed and cleanup
- Automatically prints `.sce` and `.csv` file contents to terminal for debugging

---

## Setup

### 1. Install Scilab

```bash
sudo apt update
sudo apt install scilab
```

This installs Scilab and its shared libraries (usually under `/usr/lib/scilab` and `/usr/share/scilab`).

Alternatively, you can build Scilab from source and install it system-wide using `checkinstall`.

---

### 2. Clone into your catkin workspace

```bash
cd ~/catkin_ws/src
git clone <this repository>
cd ..
catkin build scilab_optimization
```

Make sure your environment is sourced:

```bash
source devel/setup.bash
```

---

## Dependencies

- ROS (tested on Noetic)
- `roscpp`, `std_msgs`, `robotis_math`
- Scilab 6.x (via `apt` or built from source)

---

## Usage

### C++ Example

```cpp
#include "scilab_optimization/scilab_optimization.h"

robotis_framework::ScilabOptimization solver;
solver.solveRiccatiEquation(...);  // Supply A, B, Q, R matrices here
```

### CMake Configuration

Add to your `CMakeLists.txt`:

```cmake
find_package(catkin REQUIRED COMPONENTS scilab_optimization)

add_executable(your_node src/your_node.cpp)
target_link_libraries(your_node ${catkin_LIBRARIES})
```

### package.xml Configuration

Make sure to declare the dependency in your `package.xml`:

```xml
<depend>scilab_optimization</depend>
```

If using specific messages or services, include those as well.

---

## Runtime Note: Required for dynamic module loading

Some internal Scilab modules (e.g., `libscifunctions.so`) are loaded dynamically using `dlopen()`.  
These cannot be resolved via RPATH or RUNPATH, so you **must** set `LD_LIBRARY_PATH` at runtime.

### Option 1: Terminal

```bash
export LD_LIBRARY_PATH=/usr/lib/scilab:$LD_LIBRARY_PATH
rosrun your_package your_node
```

### Option 2: Inside a ROS launch file

You can set the environment variable directly inside your `.launch` file using `<env>`:

```xml
<launch>
  <env name="LD_LIBRARY_PATH" value="/usr/lib/scilab:$(env LD_LIBRARY_PATH)"/>
  <node name="your_node" pkg="your_package" type="your_node" output="screen" />
</launch>
```

This ensures that dynamically loaded Scilab libraries can be found at runtime regardless of the shell environment.

---

## API: solveRiccatiEquation()

The `solveRiccatiEquation()` method solves a discrete-time optimal control problem using the Linear Quadratic Regulator (LQR) framework.

### Problem Statement

Given system matrices `A`, `B` and cost matrices `Q`, `R`, the method computes the optimal state feedback gain `K` such that the control law:

```
u[n] = -K * x[n]
```

minimizes the cost function:

```
J = Σ { x[n]' * Q * x[n] + u[n]' * R * u[n] }
```

subject to the discrete-time linear dynamics:

```
x[n+1] = A * x[n] + B * u[n]
```

### Inputs

| Name | Description | Dimensions |
|------|-------------|------------|
| `A` | State transition matrix | (n × n) |
| `B` | Control input matrix | (n × m) |
| `Q` | State cost matrix (positive semi-definite) | (n × n) |
| `R` | Input cost matrix (positive definite) | (m × m) |

Here, `n` is the number of system states, and `m` is the number of control inputs.
For example, in a bipedal walking robot such as a humanoid with 6 actuated joints per leg, `n = 12` could represent the full state vector (e.g., joint angles and velocities for both legs), and `m = 12` would represent the control inputs as torques applied at each joint. This is typical in a walking control module like `OnlineWalkingModule`, where full joint-level torque or position control is performed on both legs.

### Outputs

| Name | Description | Dimensions |
|------|-------------|------------|
| `K` | Optimal feedback gain matrix | (m × n) |
| `S` | Solution of the Riccati equation | (n × n) |
| `E`, `E_img` | Real and imaginary parts of closed-loop eigenvalues of `A - B*K` | (n × 1) |

### Computation (Scilab Backend)

The method internally executes the following Scilab operations:

```scilab
b = B / R * B';
S = riccati(A, b, Q, 'd', 'eigen');
K = inv(B'*S*B + R) * (B'*S*A);
E = spec(A - B*K);
```

These results are then retrieved from the Scilab interpreter and returned to the C++ caller.

### Function Signature

```cpp
bool solveRiccatiEquation(
    double* K, int* row_K, int* col_K,
    double* S, int* row_S, int* col_S,
    double* E, double* E_img, int* row_E, int* col_E,
    double* A, int row_A, int col_A,
    double* B, int row_B, int col_B,
    double* Q, int row_Q, int col_Q,
    double* R, int row_R, int col_R);
```

### Notes

- The Scilab backend is launched via `.sce` script using `scilab-cli`
- The `.sce` script and `.csv` files are generated under `/dev/shm/scilab_tmp/` (RAM disk)
- Intermediate files are automatically deleted after computation
- The full contents of the generated `.sce` and `.csv` files are printed to stdout for debugging
- Output matrices are copied into the user's memory buffers. Caller must provide sufficient space.
- If Scilab execution or matrix loading fails, the method returns `false`

---
