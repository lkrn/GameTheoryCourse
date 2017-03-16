
$p1 = @('A','B','C','D')
$p2 = @('D','B','C','A')
$p3 = @('A','C','B','D')
$players = @($p1,$p2,$p3)

$initPool = New-Object Collections.Generic.List[string]
$p1 | % { $initPool.Add($_) }
$root = @{
    Pool = $initPool
    Removed = $null
    Prev = $null
    Next = New-Object Collections.Generic.List[Object]
}

function CreateDecisionTree
{
    Param(
        [object] $node
    )

    $pool = $node.Pool
    foreach($i in $pool) {
        $newPool = New-Object Collections.Generic.List[string]
        $pool | ? { $_ –ne $i } | % { $newPool.Add($_) }
        $cnode = @{
            Pool = $newPool
            Removed = $i
            Prev = $node
            Next = New-Object Collections.Generic.List[Object]
        }
        $node.Next.Add($cNode)
        if ($newPool.Count -gt 1) {
            CreateDecisionTree $cnode
        }
    }
}

function TraverseDecisionTree
{
    Param(
        [object] $node,
        [string] $path = '()'
    )

    if ($node.Removed) {
        $path += (" -> {0}" -f $node.Removed)
    }
    if ($node.Next.Count) {
        foreach ($n in $node.Next) {
            TraverseDecisionTree $n $path
        }
    }
    else {
        $path += (" -> {0}" -f $node.Pool[0])
        $path
    }
}

function ZermeloCutDecisionTree
{
    Param(
        [object] $node,
        [int] $level = 0
    )

    if ($node.Next.Count) {
        if ( ($players.Count-1) -lt $level) {
            throw ("Mismatch between Current Level ({0}) and Players Array max index ({1})" -f $level, $players.Count-1)
        }
        $playerPreferences = $players[$level]
        $bestItemIndex = [int]::MaxValue
        foreach ($n in $node.Next) {
            ZermeloCutDecisionTree $n ($level+1)
            $lastItemInPool = $n.Pool[0]
            $lastItemInPoolIndex = $playerPreferences.indexOf($lastItemInPool)
            if ($lastItemInPoolIndex -lt $bestItemIndex) {
                $bestItemIndex = $lastItemInPoolIndex
            }
        }
        $bestItem = $playerPreferences[$bestItemIndex]
        $node.Next.RemoveAll({ param($n) ($n.Pool[0] -ne $bestItem) }) | Out-Null
        $node.Pool.RemoveAll({ param($n) ($n -ne $bestItem) }) | Out-Null
    }
}


CreateDecisionTree $root
ZermeloCutDecisionTree $root
TraverseDecisionTree $root