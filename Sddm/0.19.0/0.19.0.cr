class Target < ISM::Software

    def prepare
        @buildDirectory = true
        super
    end
    
    def configure
        super

        runCmakeCommand([   "-DCMAKE_INSTALL_PREFIX=/usr",
                            "-DENABLE_JOURNALD=OFF",
                            "-DENABLE_PAM=#{option("Linux-Pam") ? "ON" : "OFF"}",
                            "-DNO_SYSTEMD=#{option("Systemd") ? "OFF" : "ON"}",
                            "-DUSE_ELOGIND=#{option("Elogind") ? "ON" : "OFF"}",
                            "-DCMAKE_BUILD_TYPE=Release",
                            "-DBUILD_TESTING=OFF",
                            ".."],
                            buildDirectoryPath)
    end
    
    def build
        super

        makeSource(path: buildDirectoryPath)
    end
    
    def prepareInstallation
        super

        makeDirectory("#{builtSoftwareDirectoryPath(false)}#{Ism.settings.rootPath}etc")

        makeSource(["DESTDIR=#{builtSoftwareDirectoryPath}#{Ism.settings.rootPath}","install"],buildDirectoryPath)

        sddmConfData = <<-CODE
        [General]
        InputMethod=
        CODE
        fileWriteData("#{builtSoftwareDirectoryPath(false)}#{Ism.settings.rootPath}etc/sddm.conf",sddmConfData)

        makeLink("login","#{builtSoftwareDirectoryPath(false)}#{Ism.settings.rootPath}etc/pam.d/system-login",:symbolicLink)
    end

    def install
        super

        runGroupAddCommand(["-r","-g","219","sddm"])
        runUserAddCommand(["-u219","-g219","-m","-d","/var/lib/sddm","-G","video","sddm"])
        setPermissions("#{Ism.settings.rootPath}var/lib/sddm",0o755)
        setOwner("#{Ism.settings.rootPath}var/lib/sddm","sddm","sddm")
    end

end
