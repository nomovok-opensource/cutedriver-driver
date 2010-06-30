@echo off
del /F /Q pkg\
cmd /c "gem uninstall testability-driver -a -x -I"
cmd /c "rake gem"
cmd /c "gem install pkg\testability-driver*.gem --LOCAL --no-ri --no-rdoc"
