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
                            "-DNO_SYSTEMD=#{option("Systemd") ? "ON" : "OFF"}",
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

        makeDirectory("#{builtSoftwareDirectoryPath(false)}#{Ism.settings.rootPath}var/lib/sddm")
    end

    def install
        super

        runGroupAddCommand(["sddm"])
        setPermissions("#{Ism.settings.rootPath}var/lib/sddm",0o755)
        setOwner("#{Ism.settings.rootPath}var/lib/sddm","sddm","sddm")
        runUserAddCommand(["-m","-d","#{Ism.settings.rootPath}var/lib/sddm","sddm","-g","video"])
    end

end
