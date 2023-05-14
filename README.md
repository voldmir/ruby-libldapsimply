# ruby-libldapsimply

Обвёртка для си библиотеки «libldapsimply».
Перед установкой обязательно скомпилировать и установить из исходных кодов библиотеку «libldapsimply», 
исходный код: https://github.com/voldmir/libldapsimply

# Сборка для ALT Linux P9

cd ~/

git clone https://github.com/voldmir/ruby-libldapsimply

cd ruby-libldapsimply

gem build libldapsimply.gemspec

gem install ./libldapsimply-0.1.0.gem


