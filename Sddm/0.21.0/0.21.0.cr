class Target < ISM::Software

    def prepare
        @buildDirectory = true
        super
    end
    
    def configure
        super

        runCmakeCommand(arguments:  "-DCMAKE_INSTALL_PREFIX=/usr                                        \
                                    -DRUNTIME_DIR=/run/sddm                                             \
                                    -DDATA_INSTALL_DIR=/usr/share/sddm                                  \
                                    -DDBUS_CONFIG_FILENAME=sddm_org.freedesktop.DisplayManager.conf     \
                                    -DENABLE_JOURNALD=OFF                                               \
                                    -DENABLE_PAM=#{option("Linux-Pam") ? "ON" : "OFF"}                  \
                                    -DNO_SYSTEMD=#{option("Systemd") ? "ON" : "OFF"}                    \
                                    -DUSE_ELOGIND=#{option("Elogind") ? "ON" : "OFF"}                   \
                                    -DCMAKE_BUILD_TYPE=Release                                          \
                                    -DBUILD_WITH_QT6=ON                                                 \
                                    -DBUILD_TESTING=OFF                                                 \
                                    ..",
                        path:       buildDirectoryPath)
    end
    
    def build
        super

        makeSource(path: buildDirectoryPath)
    end
    
    def prepareInstallation
        super

        makeDirectory("#{builtSoftwareDirectoryPath}#{Ism.settings.rootPath}etc")

        makeSource( arguments:  "DESTDIR=#{builtSoftwareDirectoryPath}#{Ism.settings.rootPath} install",
                    path:       buildDirectoryPath)

        sddmConfData = <<-CODE
        [General]
        InputMethod=
        [Theme]
        Current=breeze
        [X11]
        EnableHiDPI=true
        [Wayland]
        EnableHiDPI=true
        CODE
        fileWriteData("#{builtSoftwareDirectoryPath}#{Ism.settings.rootPath}etc/sddm.conf",sddmConfData)

        if option("Linux-Pam")
            makeDirectory("#{builtSoftwareDirectoryPath}#{Ism.settings.rootPath}etc/pam.d")

            sddmData = <<-CODE
            auth     requisite      pam_nologin.so
            auth     required       pam_env.so
            auth    optional       pam_kwallet5.so

            auth     required       pam_succeed_if.so uid >= 1000 quiet
            auth     include        system-auth

            account  include        system-account
            password include        system-password

            session  required       pam_limits.so
            session  include        system-session
            session optional       pam_kwallet5.so auto_start
            CODE
            fileWriteData("#{builtSoftwareDirectoryPath}#{Ism.settings.rootPath}etc/pam.d/sddm",sddmData)

            sddmAutologinData = <<-CODE
            auth     requisite      pam_nologin.so
            auth     required       pam_env.so
            auth     required       pam_succeed_if.so uid >= 1000 quiet
            auth     required       pam_permit.so
            auth       optional    pam_kwallet5.so

            account  include        system-account

            password required       pam_deny.so

            session  required       pam_limits.so
            session  include        system-session
            session    optional    pam_kwallet5.so auto_start
            CODE
            fileWriteData("#{builtSoftwareDirectoryPath}#{Ism.settings.rootPath}etc/pam.d/sddm-autologin",sddmAutologinData)

            sddmGreeterData = <<-CODE
            auth     required       pam_env.so
            auth     required       pam_permit.so

            account  required       pam_permit.so
            password required       pam_deny.so
            session  required       pam_unix.so
            -session optional       pam_systemd.so
            CODE
            fileWriteData("#{builtSoftwareDirectoryPath}#{Ism.settings.rootPath}etc/pam.d/sddm-greeter",sddmGreeterData)
        end

        makeLink(   target: "login",
                    path:   "#{builtSoftwareDirectoryPath}#{Ism.settings.rootPath}etc/pam.d/system-login",
                    type:   :symbolicLink)

        if !option("Breeze")
            deleteDirectory("#{builtSoftwareDirectoryPath}#{Ism.settings.rootPath}usr/share/sddm/themes/breeze")
        end

        if !option("Elarun")
            deleteDirectory("#{builtSoftwareDirectoryPath}#{Ism.settings.rootPath}usr/share/sddm/themes/elarun")
        end

        if !option("Maldives")
            deleteDirectory("#{builtSoftwareDirectoryPath}#{Ism.settings.rootPath}usr/share/sddm/themes/maldives")
        end

        if !option("Maya")
            deleteDirectory("#{builtSoftwareDirectoryPath}#{Ism.settings.rootPath}usr/share/sddm/themes/maya")
        end
    end

    def install
        super

        runChmodCommand("0755 /var/lib/sddm")
        runChownCommand("-R sddm:sddm /var/lib/sddm")
    end

end
