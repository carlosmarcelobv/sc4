#script em powershell para inicialização do simcity de modos e telas diferentes e pré-definidos

#cm 10/23 - v001 - www.familiaquadrada.com - versão inicial
#cm 01/24 - v002 - www.familiaquadrada.com - aumento de prioridade de CPU (preventivo, não aumenta velocidade do jogo)
#cm 09/24 - v003 - www.familiaquadrada.com - removido prioridade de CPU; adicionado opções para inicilização mais rápida, alterando o controlador do NAM vigente; alterada a ordem do menu; algumas melhorias para log

#parâmetros para execução do script diretamente, sem exibição do menu
#o primeiro é o modo (m) e o segundo é o formato da tela (t)
param ([string]$m, [string]$t)

#para restringir a execução de scripts
#Set-ExecutionPolicy Restricted e Set-ExecutionPolicy RemoteSigned

#versão do script
$versaoScript = "v003"

#local do executável
$localSC4 = $env:cmjgsc4 + "\Apps\SimCity 4.exe"

#exemplo de tripa de parâmetros a montar
#-intro:off -CPUcount:1 -audio:on -UserDir:"%cmjgsc4mod%\" -CustomResolution:enabled -r1600x900x32 -w
$tripa = ""

#parâmetros fixos
#$paramSempre = " -intro:off -audio:on -CPUcount:1 -CPUPriority:High "
$paramSempre = " -intro:off -audio:on -CPUcount:1 "
$tripa = $paramSempre

#modo de jogo: quais plugins e quais regiões a carregar
$sc4mod = $env:cmjgsc4mod
$baunilha = "-UserDir:`"" + $sc4mod + "\variacoes\baunilha\`""
$minPlugins = "-UserDir:`"" + $sc4mod + "\variacoes\minimo\`""
$maxPlugins = "-UserDir:`"" + $sc4mod + "\variacoes\usual\`""
$maxPluginsNAM = $sc4mod + "\variacoes\usual\"
$maxPluginsNAM += "Plugins\transporte\nam\0 NAM Controller_RHD_4GB_Full\"
$modoJogo = $baunilha #valor padrão
$modoNam = "ComNAM" #valor padrão

#modo de jogo NAM: troca do controlador do NAM, renomeando o arquivo controlador indesejado com ".fora" para não ser carregado
#antes de começar, devemos renomear os arquivos para garantir que estejam no modo padrão (controlador nam completo)
#esta ação deve ser feita nesse momento pois não é viável renomear de volta ao padrão após a execução do script
$maxPluginsComNAMForaPadrao = $maxPluginsNAM + "NetworkAddonMod_Controller.dat.fora"
$maxPluginsComNAMNoooPadrao = $maxPluginsNAM + "NetworkAddonMod_Controller.dat"
$maxPluginsRedNAMForaPadrao = $maxPluginsNAM + "NetworkAddonMod_ControllerNoRHW.dat"
$maxPluginsRedNAMNoooPadrao = $maxPluginsNAM + "NetworkAddonMod_ControllerNoRHW.dat.fora"

#Se o arquivo não existir, é porque o nome está correto, nada precisa ser feito
if (Test-Path -Path $maxPluginsComNAMForaPadrao) {
	Rename-Item -Path $maxPluginsComNAMForaPadrao -NewName $maxPluginsComNAMNoooPadrao
}
#Se o arquivo não existir, é porque o nome está correto, nada precisa ser feito
if (Test-Path -Path $maxPluginsRedNAMForaPadrao) {
	Rename-Item -Path $maxPluginsRedNAMForaPadrao -NewName $maxPluginsRedNAMNoooPadrao
}

#parâmetros de tela (em caso de incapacidade de usar essas resoluções, ele iniciará como 800x600)
$tamTelaP = " -CustomResolution:enabled -r1360x768x32 -f" #tela cheia, mais CONFORTO
$tamTelaM = " -CustomResolution:enabled -r1600x900x32 -w" #janela, uso geral
$tamTelaG = " -CustomResolution:enabled -r1920x1080x32 -f" #tela cheia, visão mais AMPLA (padrão)
$tamTelaGG = " -CustomResolution:enabled -r2048x1152x32 -f" #para computadores com placa de vídeo possante
$tamTela = $tamTelaM #valor padrão

function defineModo
{	param([string]$dmodo)
	switch ($dmodo)
	{	1 { return $baunilha }
		2 { return $minPlugins }
		3 { 
			$modoNam = defineModoNam("ComNAM")
			return $maxPlugins 
		}
		4 {
			$modoNam = defineModoNam("RedNAM")
			return $maxPlugins
		}
		5 { 
			$modoNam = defineModoNam("SemNAM")
			return $maxPlugins
		}
		6 { exit }
		"puro" { return $baunilha }
		"minlab" { return $minPlugins }
		"completo" { 
			$modoNam = defineModoNam("ComNAM")
			return $maxPlugins
		}
		"completoRedNam" { 
			$modoNam = defineModoNam("RedNAM")
			return $maxPlugins 
		}
		"completoSemNam" { 
			$modoNam = defineModoNam("SemNAM")
			return $maxPlugins 
		}
		default { return "vz" }
	}
}

function defineModoNam
{	param([string]$dmodoNam)
	switch ($dmodoNam)
	{	"ComNAM" {
			#carregará o controlador nam completo: o controlador reduzido (noRHW) ficará com ".fora"
			if (Test-Path -Path $maxPluginsComNAMForaPadrao) {
				Rename-Item -Path $maxPluginsComNAMForaPadrao -NewName $maxPluginsComNAMNoooPadrao
			}
			if (Test-Path -Path $maxPluginsRedNAMForaPadrao) {
				Rename-Item -Path $maxPluginsRedNAMForaPadrao -NewName $maxPluginsRedNAMNoooPadrao
			}
			return "ComNAM"
		}
		"RedNAM" {
			#carregará o controlador nam reduzido (noRHW): o controlador completo ficará com ".fora"
			if (Test-Path -Path $maxPluginsComNAMNoooPadrao) {
				Rename-Item -Path $maxPluginsComNAMNoooPadrao -NewName $maxPluginsComNAMForaPadrao
			}
			if (Test-Path -Path $maxPluginsRedNAMNoooPadrao) {
				Rename-Item -Path $maxPluginsRedNAMNoooPadrao -NewName $maxPluginsRedNAMForaPadrao
			}
			return "SemNAM"
		}
		"SemNAM" {
			#sem o controlador nam: ambos os controladores ficarão com ".fora"
			if (Test-Path -Path $maxPluginsComNAMNoooPadrao) {
				Rename-Item -Path $maxPluginsComNAMNoooPadrao -NewName $maxPluginsComNAMForaPadrao
			}
			if (Test-Path -Path $maxPluginsRedNAMForaPadrao) {
				Rename-Item -Path $maxPluginsRedNAMForaPadrao -NewName $maxPluginsRedNAMNoooPadrao
			}
			return "RedNAM"
		}
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
		Write-Host "1. baunilha ou speedrun"
		Write-Host "2. rápido ou laboratório"
		Write-Host "3. completo"
		Write-Host "4. completo, NAM reduzido (noRHW)"
		Write-Host "5. completo, sem controlador NAM"
		Write-Host "6. sair"
		$inputModo = Read-Host "Digite a opção desejada (1-6) "
		$modoJogoAqui = defineModo ($inputModo)
		if ($modoJogoAqui -eq "vz")
		{	Write-Host "Opção de modo inválida, tente novamente. " $modoJogoAqui
		}
		Write-Host ""
	}
	until ($inputModo -ge 1 -and $inputModo -le 6)
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
		$inputTela = Read-Host "Digite a opção desejada (1-5) "
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
	$arqlog = $sc4mod + "\ajustes\sc4-log-" + $versaoScript + ".txt"
	$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
	
	#logar a tripa chamada com data e hora
	Add-Content -Path $arqlog -Value ($timestamp + "`t" + $flagErro + "`t" + $versaoScript + "`t" + $modoNam + "`t" + $localSC4 + $tripa)
	if ($flagErro -ceq "DEURUIM")
	{	Add-Content -Path $arqlog -Value ($timestamp + "`tVERBORRAGIA:`t" + $versaoScript + "`t" + $modoNam + "`t" +$erroMsg)
	}
	exit
}

