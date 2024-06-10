class Target < ISM::Software
    
    def prepareInstallation
        super

        makeDirectory("#{builtSoftwareDirectoryPath}#{Ism.settings.rootPath}etc/conf.d")
        makeDirectory("#{builtSoftwareDirectoryPath}#{Ism.settings.rootPath}usr/bin")

        displayManagerData = <<-CODE
        CHECKVT=7
        DISPLAYMANAGER=""
        CODE
        fileWriteData("#{builtSoftwareDirectoryPath}#{Ism.settings.rootPath}etc/conf.d/display-manager",displayManagerData)

        prepareOpenrcServiceInstallation("#{buildDirectoryPath}/Display-Manager-Setup-Init.d","display-manager-setup")
        prepareOpenrcServiceInstallation("#{buildDirectoryPath}/Display-Manager-Init.d","display-manager")
        copyFile("#{buildDirectoryPath}/startDM","#{builtSoftwareDirectoryPath}#{Ism.settings.rootPath}usr/bin/startDM")
        runChmodCommand(["+x","startDM"],"#{builtSoftwareDirectoryPath}#{Ism.settings.rootPath}usr/bin")
    end

end
