#include <iostream>

int main() {
    std::cout << "Hello, World!" << std::endl;
#ifdef __linux__
    std::cout << "Linux OS";

#endif
    return 0;
}
