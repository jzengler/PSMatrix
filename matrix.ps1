# print symbol to console
function setSymbol($x, $y, $symbol){
    
    $x -= $x%2
    

    if( $y -in 0..$yMax){
        

        if($symbol -notin 0..1 ){
            
            #$symbol = [char]$(get-random -Minimum 33 -maximum 126)
            $symbol = [char]$(get-random -Minimum 512 -maximum 1023)
            #$symbol = [char]$(get-random -Minimum 161 -maximum 687)
        }

        $coord.x = $x; $coord.y = $y
        $host.ui.rawui.CursorPosition = $coord
        write-host $symbol -ForegroundColor "white"


        $coord.x = $x; $coord.y = $y
        $host.ui.rawui.CursorPosition = $coord
        write-host $symbol -ForegroundColor "green"
    }
    
}

# remove symbol from console
function remSymbol($x, $y){
    
    $x -= $x%2
    
    if($y -in 0..$yMax){
        $coord.x = $x; $coord.y = $y
        $host.ui.rawui.CursorPosition = $coord
        write-host " "
    }
}

function preload(){

    
    Add-Type -AssemblyName System.Windows.Forms
    [System.Windows.Forms.SendKeys]::SendWait("{F11}");

    $global:coord = new-object system.management.automation.host.coordinates 0,0
    $OutputEncoding = [console]::InputEncoding = [console]::OutputEncoding = New-Object System.Text.UTF8Encoding
    $host.ui.rawui.BackgroundColor = "Black"
    $host.ui.rawui.ForegroundColor = "Green"
    $global:yMax = $host.ui.rawui.WindowSize.Height - 2
    $global:xMax = $host.ui.rawui.WindowSize.Width - 1
    Clear-Host

    $host.UI.RawUI.CursorSize = 100
    $host.ui.RawUI.WindowTitle = ""
    $name = "Wake up, $env:username...".ToCharArray()
    
    foreach($c in $name){
    write-host $c -NoNewline
    Start-Sleep -Milliseconds $(get-random -min 25 -max 200)
    }
    Start-Sleep 2
    Clear-Host

    $host.UI.RawUI.CursorSize = 0
    foreach($y in 0..$yMax){
    foreach($x in $($xMax/2 - 8)..$(($xMax/2) + 8)){
        if($x%2 -eq 1){
                setSymbol $x $y $(get-random -min 0 -max 2)
         }
         
    }
    Start-Sleep -Milliseconds 50
    }

   $host.ui.RawUI.WindowTitle = "accessing mainframe..."
    
   $con = @()
   $con +=  "#######################"
   $con +=  "#                     #"
   $con +=  "#      connected      #"
   $con +=  "#                     #"
   $con +=  "#######################"

    $coord.x = $xMax/2 - 11; $coord.y = $yMax/3
    $host.ui.rawui.CursorPosition = $coord
    
    foreach($line in $con){
    $coord.x = $xMax/2 - 12; $coord.y++
    $host.ui.rawui.CursorPosition = $coord
    write-host $line -ForegroundColor "green"
    }
    Start-Sleep 2
    Clear-Host
}

# setup env
function init(){
    
   
    Clear-Host
    

    #generate columns according to window width, looks best to when not cluttered
    $maxCols = $yMax/5

    # generate arrays of maxCol size and fill them with random starting postitions
    $xSet=@()
    $y = @()
    $lead=@()
        foreach($n in 1..$maxCols){
            $xSet += get-random -Minimum 0 -Maximum $xMax
            $y += get-random -Minimum 0 -Maximum $xMax
            $lead += get-random -minimum 0 -maximum $yMax
       }

    $host.ui.RawUI.WindowTitle = "scanning..."
    return $xSet, $y, $lead
}


# main loop
function main(){
    
    #set arrays and visual sugar before starting
    $xSet, $y, $lead = init
    
    #infinite loop
    while(1){

     # reset inner loop counter
     $i = 0
    
     # start inner loop
     while($i -lt $yMax){
            
            #get height and width of console window in case its resized
            $yCur = $host.ui.rawui.WindowSize.Height - 2
            $xCur = $host.ui.rawui.WindowSize.Width - 1

            # if window is resized from last iteration reload
           if($($yCur -ne $ymax) -or $($xCur -ne $xMax)){
                Clear-Host
                $global:yMax = $host.ui.rawui.WindowSize.Height - 2
                $global:xMax = $host.ui.rawui.WindowSize.Width - 1
                $xSet, $y, $lead = init
            }
           
           #loop for every column indicated by elements in y
           foreach($j in 0..$($y.Length - 1)){
               
               #keep y element within window bounds
               $y[$j] = $y[$j]%$yMax
               
               #set symbol in x y postion
               setSymbol $xSet[$j] $y[$j]
               
               # remove one column every other iteration
               
               remSymbol $lead[$j] $y[$j]
               
               
               
               #reached end of window
               if($y[$j] -eq $yMax-1){
                 
                 # set and remove last symbols before resetting
                 setSymbol $xSet[$j] $($y[$j]+1)
                 
                 remSymbol $lead[$j] $($y[$j]+1)
                
                 
                 # get new x axis postitions for set and remove columns
                 $xSet[$j] = get-random -Minimum 0 -Maximum $xMax
                 $lead[$j] = get-random -Minimum 0 -Maximum $xMax
               }
               # keep removing next symbol before setting next round
               else{
                remSymbol $xSet[$j] $($y[$j]+1)
               }

                #increment to next y position in column
                $y[$j]++
           }
            
            # increment loop counter
            $i++
        
     }

    }
}


preload
main