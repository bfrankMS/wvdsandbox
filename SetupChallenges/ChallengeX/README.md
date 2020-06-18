# Challenge X: What's next?  

  
[back](../../README.md)
  
Hopefully you now have a running WVD sandbox to play with...  
...below is my recommended **playlist with things for you to try out**  
have fun.  

1. **Publish applications** by perfoming the [Tutorial: Manage app groups with the Azure portal](hhttps://docs.microsoft.com/en-us/azure/virtual-desktop/manage-app-groups).
2. **Connect to your WVD sandbox using different clients**: Connect with the...
    - [Windows Desktop Client](https://docs.microsoft.com/en-us/azure/virtual-desktop/connect-windows-7-and-10)
    - [Web client](https://docs.microsoft.com/en-us/azure/virtual-desktop/connect-web)
    - [Android client](https://docs.microsoft.com/en-us/azure/virtual-desktop/connect-android)
    - [macOS client](https://docs.microsoft.com/en-us/azure/virtual-desktop/connect-macos)
    - [iOs client](https://docs.microsoft.com/en-us/azure/virtual-desktop/connect-ios)
3. **[Create an custom Windows 10 multi-session image](https://christiaanbrinkhoff.com/2020/05/01/windows-virtual-desktop-technical-2020-spring-update-arm-based-model-deployment-walkthrough/#CreateacustomWindows10multi-session-AzureManagedimage)**. e.g. install: applications, language packs, change keyboard layout, time zone,...
4. [**Add FSLogix Profile Container** as a profile delivery solution](https://christiaanbrinkhoff.com/2020/05/01/windows-virtual-desktop-technical-2020-spring-update-arm-based-model-deployment-walkthrough/#AddFSLogixProfileContainerasprofiledeliverysolution) = **user profile folder redirection**. See also [Tutorial: Configure Profile Container to redirect User Profiles](https://docs.microsoft.com/en-us/fslogix/configure-profile-container-tutorial)
5. [**Enable Azure Multi-Factor Auth**entication for Windows Virtual Desktop](https://docs.microsoft.com/en-us/azure/virtual-desktop/set-up-mfa)
6. **Configure WVD Monitoring** as you [Use Log Analytics for the diagnostics feature](https://docs.microsoft.com/en-us/azure/virtual-desktop/diagnostics-log-analytics)
7. Implement **3rd party tools from sepago** (Monitoring, autoscale, User self service, Azure Admin for WVD) - go [here](https://www.sepago.de/en/wvd-value-add-tools/)
- **Implement e.g. Audio and video redirection** using [Customize Remote Desktop Protocol properties for a host pool](https://docs.microsoft.com/en-us/azure/virtual-desktop/customize-rdp-properties) - see also [Supported Remote Desktop RDP file settings for Device redirection](https://docs.microsoft.com/en-us/windows-server/remote/remote-desktop-services/clients/rdp-files?context=/azure/virtual-desktop/context/context#device-redirection)
- [**Use Microsoft Teams** on Windows Virtual desktop](https://docs.microsoft.com/en-us/azure/virtual-desktop/teams-on-wvd)
- [Set up **MSIX app attach**](https://docs.microsoft.com/en-us/azure/virtual-desktop/app-attach) = the future of app delivery - pack and attach your application for better app virtualization.
- Use **GPU enabled VMs** sizes **for** Host pool VMs to **build a hardware accelerated WVD 3D CAD desktop**. Check out [Configure graphics processing unit (GPU) acceleration for Windows Virtual Desktop](https://docs.microsoft.com/en-us/azure/virtual-desktop/configure-vm-gpu)
- **[Implement FSLogix Application Masking](https://docs.microsoft.com/en-us/fslogix/implement-application-masking-tutorial)**
- **Automate the deployment** using [PowerShell](https://docs.microsoft.com/en-us/azure/virtual-desktop/powershell-module) and/or ARM
- **Test printing** in WVD desktop (e.g. HTML5 session, Remote Desktop Session) or tryout 3rd party printing solutions [see WVD Partners](https://docs.microsoft.com/en-us/azure/virtual-desktop/partners) 
- Analyze cost / usage with Azure Cost 
- ... 

I hope the sandbox was useful for you.  
**Take care!**

