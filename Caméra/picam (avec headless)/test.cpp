#include <iostream>
#include <fstream>

int main() {
    std::ifstream fin("settings.conf");
    double a, b, c, d, e, f, g;
    fin >> a >> b >> c >> d >> e >> f >> g;
    std::cout << " " << a << " " << b << " " << c << '\n';
        fin >> a >> b >> c >> d >> e >> f >> g;
    std::cout << " " << a << " " << b << " " << c << '\n';

    fin >> a >> b >> c >> d >> e >> f >> g;
    std::cout << " " << a << " " << b << " " << c << '\n';

}