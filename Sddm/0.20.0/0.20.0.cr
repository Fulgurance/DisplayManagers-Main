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

        if option("Linux-Pam")
            makeDirectory("#{builtSoftwareDirectoryPath(false)}#{Ism.settings.rootPath}etc/pam.d")

            sddmData = <<-CODE
            auth     requisite      pam_nologin.so
            auth     required       pam_env.so

            auth     required       pam_succeed_if.so uid >= 1000 quiet
            auth     include        system-auth

            account  include        system-account
            password include        system-password

            session  required       pam_limits.so
            session  include        system-session
            CODE
            fileWriteData("#{builtSoftwareDirectoryPath(false)}#{Ism.settings.rootPath}etc/pam.d/sddm",sddmData)

            sddmAutologinData = <<-CODE
            auth     requisite      pam_nologin.so
            auth     required       pam_env.so

            auth     required       pam_succeed_if.so uid >= 1000 quiet
            auth     required       pam_permit.so

            account  include        system-account

            password required       pam_deny.so

            session  required       pam_limits.so
            session  include        system-session
            CODE
            fileWriteData("#{builtSoftwareDirectoryPath(false)}#{Ism.settings.rootPath}etc/pam.d/sddm-autologin",sddmAutologinData)

            sddmGreeterData = <<-CODE
            auth     required       pam_env.so
            auth     required       pam_permit.so

            account  required       pam_permit.so
            password required       pam_deny.so
            session  required       pam_unix.so
            -session optional       pam_systemd.so
            CODE
            fileWriteData("#{builtSoftwareDirectoryPath(false)}#{Ism.settings.rootPath}etc/pam.d/sddm-greeter",sddmGreeterData)
        end
    end

    def install
        super

        runGroupAddCommand(["-r","-g","219","sddm"])
        runUserAddCommand(["-u219","-g219","-m","-d","/var/lib/sddm","-G","video","sddm"])
        setPermissions("#{Ism.settings.rootPath}var/lib/sddm",0o755)
        setOwner("#{Ism.settings.rootPath}var/lib/sddm","sddm","sddm")
        makeLink("login","#{Ism.settings.rootPath}etc/pam.d/system-login",:symbolicLink)
    end

end
