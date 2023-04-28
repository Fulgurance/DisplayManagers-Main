class Target < ISM::Software
    
    def prepare
    end

    def prepareInstallation
        super

        makeDirectory("#{builtSoftwareDirectoryPath(false)}#{Ism.settings.rootPath}etc/conf.d")
        makeDirectory("#{builtSoftwareDirectoryPath(false)}#{Ism.settings.rootPath}usr/bin")

        displayManagerData = <<-CODE
        CHECKVT=7
        DISPLAYMANAGER=""
        CODE
        fileWriteData("#{builtSoftwareDirectoryPath(false)}#{Ism.settings.rootPath}etc/conf.d/display-manager.conf",displayManagerData)

        prepareOpenrcServiceInstallation("#{workDirectoryPath(false)}/display-manager-setup.initd-r1","display-manager-setup")
        prepareOpenrcServiceInstallation("#{workDirectoryPath(false)}/display-manager.initd-r5","display-manager")
        copyFile("#{workDirectoryPath(false)}/startDM-r1","#{builtSoftwareDirectoryPath(false)}#{Ism.settings.rootPath}usr/bin/startDM")
        runChmodCommand(["+x","#{builtSoftwareDirectoryPath(false)}#{Ism.settings.rootPath}usr/bin/startDM"])
    end

end
