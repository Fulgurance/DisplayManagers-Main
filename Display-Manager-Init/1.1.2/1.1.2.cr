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

        prepareOpenrcServiceInstallation(   path:   "#{buildDirectoryPath}/Display-Manager-Setup-Init.d",
                                            name:   "display-manager-setup")
        prepareOpenrcServiceInstallation(   path:   "#{buildDirectoryPath}/Display-Manager-Init.d",
                                            name:   "display-manager")

        copyFile(   "#{buildDirectoryPath}/startDM",
                    "#{builtSoftwareDirectoryPath}#{Ism.settings.rootPath}usr/bin/startDM")

        runChmodCommand(arguments:  "+x startDM",
                        path:       "#{builtSoftwareDirectoryPath}#{Ism.settings.rootPath}usr/bin")
    end

end
