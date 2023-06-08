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

        makeSource(["DESTDIR=#{builtSoftwareDirectoryPath}#{Ism.settings.rootPath}","install"],buildDirectoryPath)
    end

    def install
        super

        runGroupAddCommand(["-r","-g","219","sddm"])
        runUserAddCommand(["-U","-u111","-m","-d","#{Ism.settings.rootPath}var/lib/sddm","sddm","-G","sddm,video"])
        setPermissions("#{Ism.settings.rootPath}var/lib/sddm",0o755)
        setOwner("#{Ism.settings.rootPath}var/lib/sddm","sddm","sddm")
        makeLink("login","#{Ism.settings.rootPath}etc/pam.d/system-login",:symbolicLink)
    end

end
