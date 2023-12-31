#script em powershell para inicialização do simcity de modos e telas diferentes e pré-definidos

#cm 10/23 - v01 - #versão inicial - www.familiaquadrada.com

#parâmetros para execução do script diretamente, sem exibição do menu
#o primeiro é o modo (m) e o segundo é o formato da tela (t)
param ([string]$m, [string]$t)

#para restringir a execução de scripts
#Set-ExecutionPolicy Restricted e Set-ExecutionPolicy RemoteSigned

#local do executável
$localSC4 = $env:cmjgsc4 + "\Apps\SimCity 4.exe"

#exemplo de tripa de parâmetros a montar
#-intro:off -CPUcount:1 -audio:on -UserDir:"%cmjgsc4mod%\" -CustomResolution:enabled -r1600x900x32 -w
$tripa = ""

#parâmetros fixos
$paramSempre = " -intro:off -CPUcount:1 -audio:on "

#modo de jogo: plugins e regiões a carregar
$sc4mod = $env:cmjgsc4mod
$baunilha = "-UserDir:`"" + $sc4mod + "\variacoes\baunilha\`""
$minPlugins = "-UserDir:`"" + $sc4mod + "\variacoes\minimo\`""
$maxPlugins = "-UserDir:`"" + $sc4mod + "\variacoes\usual\`""
$modoJogo = $baunilha #valor padrão

#parâmetros de tela (em caso de incapacidade de usar essas resoluções, ele iniciará como 800x600)
$tamTelaP = " -CustomResolution:enabled -r1360x768x32 -f" #tela cheia, mais CONFORTO
$tamTelaM = " -CustomResolution:enabled -r1600x900x32 -w" #janela, uso geral
$tamTelaG = " -CustomResolution:enabled -r1920x1080x32 -f" #tela cheia, visão mais AMPLA (padrão)
$tamTelaGG = " -CustomResolution:enabled -r2048x1152x32 -f" #para computadores com placa de vídeo possante
$tamTela = $tamTelaM #valor padrão

$tripa = $paramSempre

function defineModo
{	param([string]$dmodo)
	switch ($dmodo)
	{	1 { return $maxPlugins }
		2 { return $minPlugins }
		3 { return $baunilha }
		4 { exit }
		"completo" { return $maxPlugins }
		"minlab" { return $minPlugins }
		"puro" { return $baunilha }
		default { return "vz" }
	}
}

function defineTela
{	param([string]$dtela)
	switch ($dtela)
	{	1 { return $tamTelaP }
		2 { return $tamTelaM }
		3 { return $tamTelaG }
		4 { return $tamTelaGG }
		5 { exit }
		"conforto" { return $tamTelaP }
		"janela" { return $tamTelaM }
		"amplo" { return $tamTelaG }
		"ampla" { return $tamTelaG }
		"rico" { return $tamTelaGG }
		default { return "vz" }
	}
}

function exibeOpcoesModo
{	do
	{	Write-Host "Escolha o modo de jogo:"
		Write-Host "1. completo (usual)"
		Write-Host "2. rápido ou laboratório"
		Write-Host "3. baunilha ou speedrun"
		Write-Host "4. sair"
		$inputModo = Read-Host "Digite a opção desejada (1-4) "
		$modoJogoAqui = defineModo ($inputModo)
		if ($modoJogoAqui -eq "vz")
		{	Write-Host "Opção de modo inválida, tente novamente. " $modoJogoAqui
		}
		Write-Host ""
	}
	until ($inputModo -ge 1 -and $inputModo -le 4)
	return $modoJogoAqui
}

function exibeOpcoesTela
{	do
	{	Write-Host "Escolha o formato de tela:"
		Write-Host "1. tela cheia, CONFORTO (menor resolução)"
		Write-Host "2. janela, para uso geral"
		Write-Host "3. tela cheia, visão AMPLA (maior resolução)"
		Write-Host "4. tela cheia, visão máxima"
		Write-Host "5. sair"
		$inputTela = Read-Host "Digite a opção desejada (1-4) "
		$tamTelaAqui = defineTela($inputTela)
		if ($tamTelaAqui -eq "vz")
		{	Write-Host "Opção de tela inválida, tente novamente. " $tamTelaAqui
		}
		Write-Host ""
	}
	until ($inputTela -ge 1 -and $inputTela -le 5)
	return $tamTelaAqui
}

function chamaTripa
{	param([string]$localSC4Aqui, [string]$tripaAqui, [string]$modoJogoAqui, [string]$tamTelaAqui)
	$tripaAqui = $tripaAqui + $modoJogoAqui + $tamTelaAqui
	Start-Process -FilePath $localSC4Aqui -ArgumentList $tripaAqui
	return $tripaAqui
}

try
{	$flagErro = "deubom"
	$modoJogo = defineModo -dmodo $m
	$tamTela = defineTela -dtela $t
	#se os 2 parâmetros estão presentes e ambos estão corretos, executar sem menu
	if (-not ( ($m -eq "") -or ($t -eq "") -or ($modoJogo -eq "vz") -or ($tamTela -eq "vz")))
	{	#monta a tripa e executa
		$tripa = chamaTripa -localSC4Aqui $localSC4 -tripaAqui $tripa -modoJogoAqui $modoJogo -tamTelaAqui $tamTela
	}
	else
	{	$modoJogo = exibeOpcoesModo
		$tamTela = exibeOpcoesTela
		$tripa = chamaTripa -localSC4Aqui $localSC4 -tripaAqui $tripa -modoJogoAqui $modoJogo -tamTelaAqui $tamTela
	}
}
catch
{	$flagErro = "DEURUIM"
	$erroMsg = $Error
	#Write-Host $erroMsg
}
finally
{	#arquivo de log
	$arqlog = ".\sc4-log.txt"
	$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
	
	#logar a tripa chamada com data e hora
	Add-Content -Path $arqlog -Value ($timestamp + "`t" + $flagErro + "`t" + $localSC4 + $tripa)
	if ($flagErro -ceq "DEURUIM")
	{	Add-Content -Path $arqlog -Value ($timestamp + "`tVERBORRAGIA:`t" + $erroMsg)
	}
	exit
}

