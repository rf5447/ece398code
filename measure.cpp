#include <windows.h>
#include <iostream>
#include <string>

// Time the simulation
int main() {
    LARGE_INTEGER frequency, start, end;
    QueryPerformanceFrequency(&frequency); // Get the ticks per second

    // Get start time
    QueryPerformanceCounter(&start);

    // Run the simulation
    STARTUPINFO si;
    PROCESS_INFORMATION pi;
    ZeroMemory(&si, sizeof(si));
    si.cb = sizeof(si);
    ZeroMemory(&pi, sizeof(pi));

    std::string command = "vvp SMTTTimingFast.out"; // Change the file name for the corresponding .out file
    if (!CreateProcess(
            NULL,
            const_cast<char*>(command.c_str()),
            NULL,
            NULL,
            FALSE,
            0,
            NULL,
            NULL,
            &si,
            &pi))
    {
        std::cerr << "CreateProcess failed (" << GetLastError() << ").\n";
        return 1;
    }

    WaitForSingleObject(pi.hProcess, INFINITE);

    // Get end time
    QueryPerformanceCounter(&end);

    double elapsedSeconds = static_cast<double>(end.QuadPart - start.QuadPart) / frequency.QuadPart;
    std::cout << "Elapsed Wall Clock Time: " << elapsedSeconds << " seconds\n";

    CloseHandle(pi.hProcess);
    CloseHandle(pi.hThread);

    return 0;
}



// #include <windows.h>
// #include <iostream>
// #include <string>

// int main() {
//     // Initialize the structures for process creation.
//     STARTUPINFO si;
//     PROCESS_INFORMATION pi;
//     ZeroMemory(&si, sizeof(si));
//     si.cb = sizeof(si);
//     ZeroMemory(&pi, sizeof(pi));

//     // Command line to run your simulation.
//     // This assumes 'vvp' is in your PATH; adjust the command if needed.
//     std::string command = "vvp SMTTTiming.out";

//     // Create the process.
//     if (!CreateProcess(
//             NULL,                          // No module name (use command line)
//             const_cast<char*>(command.c_str()), // Command line
//             NULL,                          // Process handle not inheritable
//             NULL,                          // Thread handle not inheritable
//             FALSE,                         // Set handle inheritance to FALSE
//             0,                             // No creation flags
//             NULL,                          // Use parent's environment block
//             NULL,                          // Use parent's starting directory 
//             &si,                           // Pointer to STARTUPINFO structure
//             &pi)                           // Pointer to PROCESS_INFORMATION structure
//     ) {
//         std::cerr << "CreateProcess failed (" << GetLastError() << ").\n";
//         return 1;
//     }

//     // Wait until the process finishes.
//     WaitForSingleObject(pi.hProcess, INFINITE);

//     // Variables to store process times.
//     FILETIME creationTime, exitTime, kernelTime, userTime;
//     if (GetProcessTimes(pi.hProcess, &creationTime, &exitTime, &kernelTime, &userTime)) {
//         // FILETIME values are in 100-nanosecond intervals.
//         ULARGE_INTEGER ulKernelTime, ulUserTime;
//         ulKernelTime.LowPart = kernelTime.dwLowDateTime;
//         ulKernelTime.HighPart = kernelTime.dwHighDateTime;
//         ulUserTime.LowPart = userTime.dwLowDateTime;
//         ulUserTime.HighPart = userTime.dwHighDateTime;

//         // Convert to seconds.
//         double kernelSeconds = ulKernelTime.QuadPart / 1e7;
//         double userSeconds = ulUserTime.QuadPart / 1e7;

//         std::cout << "Kernel Time (system mode): " << kernelSeconds << " seconds\n";
//         std::cout << "User Time (simulation code execution): " << userSeconds << " seconds\n";
//     } else {
//         std::cerr << "GetProcessTimes failed (" << GetLastError() << ").\n";
//     }

//     // Clean up handles.
//     CloseHandle(pi.hProcess);
//     CloseHandle(pi.hThread);

//     return 0;
// }
