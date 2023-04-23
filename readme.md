# PowerShell Wrapper for the RAC Utility
This is a PowerShell wrapper for the RAC (Remote Administration Client) utility, which allows you to remotely manage 1C:Enterprise servers. With this PowerShell module, you can manage clusters, infobases, and sessions using the RAC utility's functionality, all from the convenience of the PowerShell command line. The wrapper provides functions to create cluster administrator credentials, get clusters, infobases, and sessions, and terminate sessions.
## Saving credential
First, create your cluster administrator credential for your session.

    PS C:\> Rac-Create-ClusterCredential
    
    PowerShell credential request
    Enter your credentials.
    User: UserName
    Password for user UserName: ********************
Use helper functions `$(Rac-CU)` and `$(Rac-CUP)` to provide the cluster administrator user name and password respectively to avoid leaving your password in the command history in plain text
## Getting clusters
Use the following command to get clusters:

    Rac-Get-Clusters -hostName

Here, `-hostName` is the address of the RAS (remote administration server). The function parses RAC response and returns an array of objects.
## Getting infobases
Use the following command to get infobases:

    Rac-Get-Infobases -cluster -clusterUser -clusterUserPassword -hostName
Here, `-cluster` is a cluster object you get from `Rac-Get-Clusters`
`-clusterUser` is the name of the cluster administrator, and
`-clusterUserPassword` is the password for the cluster administrator.
### Example

    PS C:\> Rac-Get-Infobases $(Rac-Get-Clusters comp1)[0] $(Rac-CU) $(Rac-CUP) comp1 | Format-Table -Property name,infobase
    name                infobase
    ----                --------
    ib1       00000000-0000-0000-0000-000000000000
    ib2       00000000-0000-0000-0000-000000000000
## Getting sessions
Use the following command to get all sessions on a cluster:

     Rac-Get-Sessions -cluster -clusterUser -clusterUserPassword -hostName 

### Example

    Rac-Get-Sessions $cluster $(Rac-CU) $(Rac-CUP) comp1
    
    calls-all                        : 000
    calls-last-5min                  : 00
    duration current-dbms            : 0
    ...
## Getting sessions for an infobase
Use the following command to get sessions for a given infobase on a cluster:

    Rac-Get-InfobaseSessions -infobase -clusterUser -clusterUserPassword -hostName 
Here, `-infobase` is an infobase object you get from `Rac-Get-Infobases`
## Getting processes
Use the following command to get all working processes (rphost.exe) for a cluster:

    Rac-Get-Processes -cluster -clusterUser -clusterUserPassword -hostName

## Terminating a session
Use the following command to terminate a session:

    Rac-End-Session -session -clusterUser -clusterUserPassword -hostName -message=""

Here, `-session` is a session object you get from `Rac-Get-Sessions`