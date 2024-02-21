Function showmenu {
    Clear-Host
    Write-Host "Menu para instalar servicios, etc..."
    Write-Host "1. Cambiar nombre del equipo."
    Write-Host "2. Active Directory."
    Write-Host "3. Internet Information Services."
    Write-Host "4. Reiniciar PC."
    Write-Host "5. Salir del menu."
}

Function showsubmenu2 {
    Clear-Host
    Write-Host "Menu de Active Directory"-ForegroundColor Green
    Write-Host "2.1. Instalar servicio de Active Directory."
    Write-Host "2.2. Crear usuarios en el Active Directory."
    Write-Host "2.3. Crear unidad organizativa en el Active Directory."
    Write-Host "2.4. Volver al menú principal."
}

Function showsubmenu3 {
    Clear-Host
    Write-Host "Menu de Internet Information Services."-ForegroundColor Green
    Write-Host "3.1. Instalar servicio IIS."
    Write-Host "3.2. Crear página web en IIS."
    Write-Host "3.3. Cambiar configuración de autenticación anónima."
    Write-Host "3.4. Volver al menú principal."
}

showmenu

while(($inp = Read-Host -Prompt "Elige una opción") -ne "5"){

    switch($inp){
        1 {
            Clear-Host
            $nombredelequipo = Read-Host "Inserte el nuevo nombre del equipo."
            Clear-Host
            Rename-Computer -NewName "$nombredelequipo"
            Write-Host "El nuevo nombre del equipo será $nombredelequipo " -ForegroundColor Green
            pause;
            break
        }
        2 {
            showsubmenu2
            while(($subinp = Read-Host -Prompt "Elige una opción") -ne "2.4"){
                switch($subinp){
                    2.1 {
                        Clear-Host
                        Write-Host "Instalando el servicio Active Directory." -ForegroundColor Green
                        Clear-Host
                        Write-Host "¡Rellene los datos a continuación para que la instalación sea exitosa!."  -ForegroundColor Red -BackgroundColor White
                        $modededominio = Read-Host "Inserte la version del Servidor a instalar por ejemplo Win2012R2."
                        $nombredeldomnio = Read-Host "Inserte el nombre del dominio que será de terminación .local."
                        $netbiosnamedominio = Read-Host "Inserte el nombre de la Netbios del dominio."
                        Clear-Host
                        Write-Host "Creando e instalando el Active Directory $nombredeldominio" -ForegroundColor Green
                        Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools
                        Import-Module ADDSDeployment
                        Install-ADDSForest `
                        -CreateDnsDelegation:$false `
                        -DatabasePath "C:\Windows\NTDS" `
                        -DomainMode $modededominio `
                        -DomainName "$nombredeldomnio.local" `
                        -DomainNetbiosName $netbiosnamedominio `
                        -ForestMode $modededominio `
                        -InstallDns:$true `
                        -NoRebootOnCompletion:$false `
                        -SysvolPath "C:\Windows\SYSVOL" `
                        -Force:$true
                        pause; 
                        break
                    }
                    2.2{
                        Clear-Host
                        Write-Host "¡Rellene los datos requeridos para crear el usuario!" -ForegroundColor Red -BackgroundColor White
                        $usuario = Read-Host "Inserte el nombre del usuario."
                        $usuarioinicio = Read-Host "Inserte nombre del usuario con el cual iniciara sesión."
                        $nombredominio = Read-Host "Inserte el nombre del dominio."
                        $OU = Read-Host "Inserte el nombre de la Unidad Organizativa a la que el usuario va a pertenecer."
                        $contraseña = Read-Host "Inserte una contraseña para el usuario."
                        Clear-Host
                        Write-Host "Creando Usuario......" -ForegroundColor Green
                        $password = (ConvertTo-SecureString "$contraseña" -AsPlainText -force)
                        New-ADUSer -Name $usuario -Sam $usuarioinicio -Path "OU=$OU,DC=$nombredominio,DC=local" -AccountPassword $password               
                        pause; 
                        break
                    }
                    2.3{
                        Clear-Host
                        Write-Host "¡Rellene los datos requeridos para crear la Unidad Organizativa!" -ForegroundColor Red -BackgroundColor White
                        $nombreOU = Read-Host "Inserte el nombre de la Unidad Organizativa a crear."
                        $nombredominioou = Read-Host "Inserte el nombre del dominio."
                        Clear-Host
                        Write-Host "Creando Unidad Organizativa......" -ForegroundColor Green
                        New-ADOrganizationalUnit -Name $nombreOU -Path "dc=$nombredominioou,dc=local"
                        pause; 
                        break 
                    }
                    default {
                        Write-Host -ForegroundColor Red -BackgroundColor White "Opción Incorrecta. Selecciona una opción del 2.1 al 2.2"
                        pause
                    }
                }
                showsubmenu2
            }
            break
        }
        3 {
            showsubmenu3
            while(($subinp = Read-Host -Prompt "Elige una opción") -ne "3.4"){
                switch($subinp){
                    3.1 {
                        Clear-Host
                        Write-Host "Instalando el servicio IIS" -ForegroundColor Green
                        Install-WindowsFeature -name Web-Server –IncludeManagementTools
                        pause;
                        break
                        }
                    3.2 {
                            Clear-Host
                            Write-Host "¡Rellene los datos requeridos para crear su página web en IIS!"  -ForegroundColor Red -BackgroundColor White
                            $nombredelaweb = Read-Host "Inserte el nombre de la Website"
                            $mensajepágina = Read-Host "Inserte el mensaje de su página web"
                            $carpetadesuweb = Read-Host "Inserte el nombre de la carpeta de su página web"
                            $puerto = Read-Host "Inserte el puerto para mostrar su página"
                            Clear-Host
                            Write-Host "¡Creando la página web $nombredelaweb!"
                            Import-Module webadministration

                            Set-Location IIS:\AppPools\

                            $web = New-Item C:\$carpetadesuweb\ –ItemType directory -Force

                            "<html>$mensajepágina</html>" | Out-File C:\$carpetadesuweb\index.html

                            $Website = New-Website -Name "$nombredelaweb" -HostHeader "" -Port $puerto -PhysicalPath $web  -ApplicationPool "DefaultAppPool"
                            pause;
                            break
                        }
                     3.3 {
                        Clear-Host
                        Write-Host "Cambiando la configuración de autenticación anónima" -ForegroundColor Green
                        Import-Module WebAdministration
                        $iisServer = Get-WebConfiguration -PSPath "IIS:\"
                        $authenticationSection = $iisServer.GetSection("system.webServer/security/authentication/anonymousAuthentication")
                        $authenticationSection.OverrideMode = "Allow"
                        $authenticationSection.CommitChanges()

                        pause
                        break
                    }
                    default {
                        Write-Host -ForegroundColor Red -BackgroundColor White "Opción Incorrecta. Selecciona una opción del 6.1 al 6.2"
                        pause
                    }
                }
                showsubmenu3
            }
            break
        }
        4 {
            Clear-Host
            Write-Host "Reiniciando equipo" -ForegroundColor Red
            Shutdown -r
            pause;
            break
        }
        default {
            Write-Host -ForegroundColor Red -BackgroundColor White "Opción Incorrecta. Selecciona una opción del 1 al 4"
            pause
        }
    }

    showmenu
}

