function Parse-Rac-Result {
    param (
        $lines,
        $addProperty = ""
    )
    # Initialize an empty array to hold the output objects
    $outputArray = @()

    # Initialize variables to hold the current object's properties and values
    $currentObjectProperties = @{}
    $currentObjectValues = @()

    # Iterate through the input array
    foreach ($line in $lines) {
        # Check if the line is empty, indicating the end of an object
        if ($line -eq "") {
            # Combine the current object's properties and values into a single object
            if ($addProperty -ne "") {
                $currentObjectProperties[$addProperty] = "";
            }
            $currentObject = New-Object PSObject -Property $currentObjectProperties
            $outputArray += $currentObject

            # Reset the variables for the next object
            $currentObjectProperties = @{}
            $currentObjectValues = @()
        }
        else {
            # Split the line into property and value using the first colon as the delimiter
            $lineSplit = $line.Split(":", 2)
            $propertyName = $lineSplit[0].Trim()
            $propertyValue = $lineSplit[1].Trim()

            # Add the property and value to the current object's properties
            $currentObjectProperties[$propertyName] = $propertyValue
        }
    }

    # Output the resulting array of objects
    $outputArray
}

function Rac-Get-Clusters {
    param (
        [Parameter(Position=0,Mandatory=$true)]        
        $hostName
    )
    $rawResult = rac cluster list $hostName
    Parse-Rac-Result -lines $rawResult

}

function Rac-Get-Infobases {
    param (
        [Parameter(Position=0,Mandatory=$true)]
        $cluster,
        [Parameter(Position=1,Mandatory=$true)]
        $clusterUser,
        [Parameter(Position=2,Mandatory=$true)]
        $clusterUserPassword,
        [Parameter(Position=3,Mandatory=$true)]
        $hostName        
    )

    $rawResult = rac infobase summary list --cluster=$($cluster.cluster) --cluster-user=$clusterUser --cluster-pwd=$clusterUserPassword $hostName
    $ibSummary = Parse-Rac-Result -lines $rawResult -addProperty cluster
    foreach ($ib in $ibSummary) {
        $ib.cluster = $cluster
    }
    $ibSummary
}

function Rac-Get-InfobaseSessions {
    param (
        [Parameter(Position=0,Mandatory=$true)]
        $infobase,
        [Parameter(Position=1,Mandatory=$true)]
        $clusterUser,
        [Parameter(Position=2,Mandatory=$true)]
        $clusterUserPassword,
        [Parameter(Position=3,Mandatory=$true)]
        $hostName       
    )

    $rawResult = rac session list --cluster=$($infobase.cluster.cluster) --cluster-user=$clusterUser --cluster-pwd=$clusterUserPassword --infobase=$($infobase.infobase) $hostName
    $sessions = Parse-Rac-Result $rawResult -addProperty cluster
    foreach ($session in $sessions) {
        $session.cluster = $infobase.cluster
    }
    $sessions
}

function Rac-Get-Sessions {
    param (
        [Parameter(Position=0,Mandatory=$true)]
        $cluster,
        [Parameter(Position=1,Mandatory=$true)]
        $clusterUser,
        [Parameter(Position=2,Mandatory=$true)]
        $clusterUserPassword,
        [Parameter(Position=3,Mandatory=$true)]
        $hostName       
    )

    $rawResult = rac session list --cluster=$($cluster.cluster) --cluster-user=$clusterUser --cluster-pwd=$clusterUserPassword $hostName
    $sessions = Parse-Rac-Result $rawResult -addProperty cluster
    foreach ($session in $sessions) {
        $session.cluster = $cluster
    }
    $sessions
}

function Rac-Get-Processes {
    param (
        [Parameter(Position=0,Mandatory=$true)]
        $cluster,
        [Parameter(Position=1,Mandatory=$true)]
        $clusterUser,
        [Parameter(Position=2,Mandatory=$true)]
        $clusterUserPassword,
        [Parameter(Position=3,Mandatory=$true)]
        $hostName       
    )
    $rawResult = rac process --cluster=$($cluster.cluster) --cluster-user=$($clusterUser) --cluster-pwd=$($clusterUserPassword) list $hostName
    Parse-Rac-Result $rawResult    
}

function Rac-End-Session {
    param (
        [Parameter(Position=0,Mandatory=$true)]
        $session,        
        [Parameter(Position=1,Mandatory=$true)]
        $clusterUser,
        [Parameter(Position=2,Mandatory=$true)]
        $clusterUserPassword,
        [Parameter(Position=3,Mandatory=$true)]
        $hostName,
        [Parameter(Position=4)]
        $message = ""
    )

    if($message -ne "") {
        rac session terminate --cluster=$($session.cluster.cluster) --cluster-user=$clusterUser --cluster-pwd=$clusterUserPassword --session=$($session.session) --error-message $message $hostName

    } else {
        rac session terminate --cluster=$($session.cluster.cluster) --cluster-user=$clusterUser --cluster-pwd=$clusterUserPassword --session=$($session.session) $hostName
    }

    if($LASTEXITCODE -eq 0) {
        Write-host "Сеанс $($session.'user-name') $($session.session) завершен"
    }

}

function Rac-Create-ClusterCredential {
    $global:RacClusterCredential = Get-Credential
}

function Rac-CU {
    $RacClusterCredential.UserName
}

function Rac-CUP {
    [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($RacClusterCredential.Password))
}