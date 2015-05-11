@echo off
del /F /Q pkg\
cmd /c "gem uninstall cutedriver-driver -a -x -I"
cmd /c "rake gem"
cmd /c "gem install pkg\cutedriver-driver*.gem --LOCAL --no-ri --no-rdoc"
