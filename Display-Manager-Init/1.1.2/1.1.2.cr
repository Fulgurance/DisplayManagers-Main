class Target < ISM::Software
    
    def prepareInstallation
        super

        makeDirectory("#{builtSoftwareDirectoryPath(false)}#{Ism.settings.rootPath}etc/conf.d")
        makeDirectory("#{builtSoftwareDirectoryPath(false)}#{Ism.settings.rootPath}usr/bin")

        displayManagerData = <<-CODE
        CHECKVT=7
        DISPLAYMANAGER=""
        CODE
        fileWriteData("#{builtSoftwareDirectoryPath(false)}#{Ism.settings.rootPath}etc/conf.d/display-manager",displayManagerData)

        prepareOpenrcServiceInstallation("#{buildDirectoryPath(false)}/Display-Manager-Setup-Init.d","display-manager-setup")
        prepareOpenrcServiceInstallation("#{buildDirectoryPath(false)}/Display-Manager-Init.d","display-manager")
        copyFile("#{buildDirectoryPath(false)}/startDM","#{builtSoftwareDirectoryPath(false)}#{Ism.settings.rootPath}usr/bin/startDM")
        runChmodCommand(["+x","startDM"],"#{builtSoftwareDirectoryPath}#{Ism.settings.rootPath}usr/bin")
    end

end
