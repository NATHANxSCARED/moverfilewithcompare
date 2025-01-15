@echo off
REM Script pour créer des répertoires et déplacer des fichiers
set "nbLigne=1"
REM Vérifier l'existence des fichiers CSV
if not exist ..\csv\data_individu.csv (
    echo ERROR : Le fichier ..\csv\data_individu.csv est introuvable. >> ..\logs\log.txt
    pause
    exit /b
)

if not exist ..\csv\extract6000_6999.csv (
    echo ERROR : Le fichier ..\csv\extract6000_6999.csv est introuvable. >> ..\logs\log.txt
    pause
    exit /b
)

REM Créer les répertoires logs et result s'ils n'existent pas
if not exist ..\logs mkdir ..\logs
if not exist ..\result mkdir ..\result

REM Activer le retardement des variables pour les boucles
setlocal enabledelayedexpansion

REM Nettoyer les anciens fichiers log
if exist ..\logs\log.txt del ..\logs\log.txt
if exist ..\logs\log_INFO.txt del ..\logs\log_INFO.txt
if exist ..\logs\log_ok.txt del ..\logs\log_ok.txt
if exist ..\logs\log_ko.txt del ..\logs\log_ko.txt
if exist ..\logs\batch_a_lancer.bat del ..\logs\batch_a_lancer.bat

REM Ajouter la date et l'heure dans le fichier log
for /f "tokens=1-4 delims=/ " %%a in ("%date% %time%") do (
    set currentDate=%%a-%%b-%%c
    set currentTime=%%d
)

echo Execution du script à !currentDate! !currentTime! >> ..\logs\log.txt
echo ---------------------------------------------- >> ..\logs\log.txt
echo Execution du script à !currentDate! !currentTime!


REM Lire le fichier CSV data_individu.csv et traiter chaque ligne
for /f "skip=1 tokens=1-5 delims=," %%a in (..\csv\data_individu.csv) do (

    set "id=%%a"
    set "repertoire=%%b_%%c_%%d_%%e"

    REM Supprimer les éléments problématiques 
    set "repertoire=!repertoire:,=!"
    set "repertoire=!repertoire:A�=e!"
    set "repertoire=!repertoire:a�=e!"
    REM set "repertoire=!repertoire:'=!"
    set "repertoire=!repertoire:-=_!"
    set "repertoire=!repertoire: =_!"
    set "repertoire=!repertoire: =_!"

    REM Debug: Afficher les informations de répertoire
    REM echo INFO : Répertoire: !repertoire! pour ID: !id! >> ..\logs\log.txt

    REM Initialiser le flag "found" à 0
    set "found=0"
    set "repertoire_cree=0"  REM Nouveau flag pour vérifier si le mkdir a été fait
    REM Boucle pour parcourir le fichier extract6000_6999.csv
    for /f "tokens=1,4 delims=;" %%i in (..\csv\extract6000_6999.csv) do (
        set "current_id=%%i"
        set "fichier_a_deplacer=%%j"

        REM Nettoyer l'ID et le fichier à déplacer
        set "current_id=!current_id:C0:=!"
        REM set "fichier_a_deplacer=!fichier_a_deplacer: =!"
        set "fichier_a_deplacer=!fichier_a_deplacer:C60:=!"

        REM Vérifier si l'ID correspond
        if "!id!"=="!current_id!" (
            echo INFO : Correspondance trouvée pour l'ID !id!, fichier à déplacer : !fichier_a_deplacer! >> ..\logs\log_INFO.txt
            if exist "..\data\6000_6999\!fichier_a_deplacer!" (
                REM Vérifier si le répertoire n'a pas encore été créé pour cet ID
                if !repertoire_cree!==0 (
                    echo mkdir ..\result\!repertoire! >> ..\logs\batch_a_lancer.bat
                    echo mkdir ..\result\!repertoire! 
                    mkdir ..\result\!repertoire!
                    REM echo INFO : Création du répertoire !repertoire! dans ..\result >> ..\logs\log.txt
                    set "repertoire_cree=1"
                )

                REM Ajouter la commande move dans batch_a_lancer
                echo move ..\data\6000_6999\!fichier_a_deplacer! ..\result\!repertoire! >> ..\logs\batch_a_lancer.bat
                echo move ..\data\6000_6999\!fichier_a_deplacer! ..\result\!repertoire!
                move ..\data\6000_6999\!fichier_a_deplacer! ..\result\!repertoire!
                echo INFO : Fichier !fichier_a_deplacer! déplacé vers ..\result\!repertoire!, pour l'ID !id! >> ..\logs\log_ok.txt
            ) else (
                echo ERROR: Fichier !fichier_a_deplacer! introuvable dans ..\data pour l'ID !id! >> ..\logs\log_ko.txt
            )
            set "found=1"
        )
    )

    REM Si aucune correspondance n'a été trouvée
  REM  if !found! == 0 (
        REM echo ERROR : Aucune correspondance trouvée pour l'ID !id! dans extract6000_6999.csv >> ..\logs\log.txt
  REM  )
    echo nobre de ligne = !nbLigne!
    set /a "nbLigne+=1"
)
echo Execution du script à !currentDate! !currentTime! >> ..\logs\log.txt
echo Execution du script à !currentDate! !currentTime!
REM Afficher le nombre total de lignes pertinentes traitées
echo INFO : Fin du script. Toutes les lignes de data_individu.csv ont été traitées.

pause
