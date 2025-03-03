#!/bin/bash
# Linia de deschidere pentru scriptul Bash

# Funcție pentru validarea adresei de email
function validare_email() {
    local email=$1 # Stochează adresa de email în variabila locală "email"
    if [[ "$email" =~ ^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$ ]]; then
        return 0 # Returnează 0 (succes) dacă adresa de email este validă
    else
        return 1 # Returnează 1 (eșec) dacă adresa de email nu este validă
    fi
}

# Funcție pentru înregistrarea unui utilizator nou
function inregistrare_utilizator() {
    read -p "Introduceți numele de utilizator: " username # Solicită utilizatorului să introducă un nume de utilizator

    # Verifică existența utilizatorului
    if grep -q "^$username," users.csv; then # Caută numele de utilizator în fișierul users.csv
        echo "Utilizatorul $username există deja!" # Afișează un mesaj dacă utilizatorul există deja
        return # Iese din funcție
    fi

    read -p "Introduceți adresa de email: " email # Solicită utilizatorului să introducă o adresă de email
    while ! validare_email "$email"; do # Repetă până când adresa de email este validă
        read -p "Adresa de email invalidă. Introduceți din nou: " email # Solicită din nou adresa de email dacă nu este validă
    done

    read -s -p "Introduceți parola: " password # Solicită utilizatorului să introducă o parolă (fără a afișa caracterele)
    echo # Afișează o linie nouă după citirea parolei

    # Generează un ID unic
    user_id=$RANDOM # Generează un ID unic aleatoriu pentru utilizator

    # Afișează întrebările de securitate și solicită alegerea uneia
    echo -e "${IRed}Alegeți una dintre întrebările de securitate:${NC}" # Afișează un mesaj în culoarea roșie
    echo "1. Care este numele de familie al mamei tale?" # Afișează prima opțiune
    echo "2. În ce oraș te-ai născut?" # Afișează a doua opțiune
    echo "3. Care este numele primului tău animal de companie?" # Afișează a treia opțiune
    echo -e "${BIGreen}" # Setează culoarea textului la verde intens
    read -p "Introduceți numărul întrebării alese [1-3]: " intrebare_nr # Solicită utilizatorului să aleagă o întrebare de securitate
    echo -e "${NC}" # Resetează culoarea textului la valoarea implicită

    case $intrebare_nr in # Verifică numărul întrebării alese
        1)
            intrebare_securitate="Care este numele de fată al mamei tale?" # Setează întrebarea de securitate
            read -p "$intrebare_securitate: " raspuns_securitate ;; # Solicită răspunsul la întrebarea de securitate
        2)
            intrebare_securitate="În ce oraș te-ai născut?" # Setează întrebarea de securitate
            read -p "$intrebare_securitate: " raspuns_securitate ;; # Solicită răspunsul la întrebarea de securitate
        3)
            intrebare_securitate="Care este numele primului tău animal de companie?" # Setează întrebarea de securitate
            read -p "$intrebare_securitate: " raspuns_securitate ;; # Solicită răspunsul la întrebarea de securitate
        *)
            echo "Alegere invalidă! Se va folosi întrebarea implicită." # Afișează un mesaj dacă alegerea este invalidă
            intrebare_securitate="Care este numele de familie al mamei tale?" # Setează întrebarea de securitate implicită
            read -p "$intrebare_securitate: " raspuns_securitate ;; # Solicită răspunsul la întrebarea de securitate implicită
    esac

    # Adaugă utilizatorul în fișierul users.csv
    timp=$(date '+%Y-%m-%d %H:%M:%S') # Obține data și ora curente
    echo "$username,$email,$password,$intrebare_securitate,$raspuns_securitate,$user_id,$timp" >> users.csv # Adaugă o linie nouă în fișierul users.csv cu datele utilizatorului

    # Creează directorul "home"
    mkdir -p "$HOME/DamianB/proiect/$username" # Creează un director pentru fișierele utilizatorului

    echo "Utilizatorul $username a fost înregistrat cu succes. ID-ul unic este $user_id." # Afișează un mesaj de confirmare
}

#AUTENTIFICARE
# Array pentru a stoca utilizatorii autentificați
declare -a logged_in_users # Declară un array pentru a stoca utilizatorii autentificați

# Numărul maxim de încercări permise
INCERCARI_MAXIME=3 # Setează numărul maxim de încercări permise pentru autentificare

function autentificare() {
    read -p "Introduceți numele de utilizator: " username # Solicită utilizatorului să introducă un nume de utilizator

    # Verifică existența utilizatorului în fișierul users.csv
    user_line=$(grep "^$username," users.csv) # Caută linia corespunzătoare utilizatorului în fișierul users.csv
    if [ -z "$user_line" ]; then # Verifică dacă linia este goală (utilizatorul nu există)
        echo "Utilizatorul $username nu există!" # Afișează un mesaj de eroare
        return # Iese din funcție
    fi

    # Citește parola corespunzătoare din fișierul users.csv
    password=$(echo "$user_line" | cut -d',' -f3) # Extrage parola din linia corespunzătoare utilizatorului

    attempts=0 # Inițializează numărul de încercări
    while [ $attempts -lt $INCERCARI_MAXIME ]; do # Repetă până când numărul de încercări este atins
        read -s -p "Introduceți parola: " input_password # Solicită utilizatorului să introducă parola (fără a afișa caracterele)
        echo # Afișează o linie nouă după citirea parolei

        # Verifică parola
        if [ "$input_password" == "$password" ]; then # Compară parola introdusă cu cea stocată în fișier
            # Actualizează campul "last_login" în fișierul users.csv
            timp=$(date '+%Y-%m-%d %H:%M:%S') # Obține data și ora curente
            sed -i "s/^\($username,[^,]*,[^,]*,[^,]*,[^,]*,[^,]*,\)[^,]*$/\1$timp/" users.csv # Actualizează data și ora ultimei autentificări în fișierul users.csv

            # Verifică existența directorului "home" al utilizatorului și navighează în el
            home_dir="$HOME/DamianB/proiect/$username" # Construiește calea către directorul "home" al utilizatorului
            if [ -d "$home_dir" ]; then # Verifică dacă directorul există
                cd "$home_dir" || return # Navighează în directorul "home" sau iese din funcție dacă nu se poate
            else
                echo "Directorul home pentru $username nu există!" # Afișează un mesaj de eroare dacă directorul nu există
return # Iese din funcție
            fi

            # Adaugă utilizatorul în array-ul logged_in_users
            logged_in_users+=("$username") # Adaugă numele de utilizator în array-ul de utilizatori autentificați

            echo "Autentificare reușită! Bine ai venit, $username!" # Afișează un mesaj de autentificare reușită

            # Buclă pentru a rămâne în directorul "home"
            while true; do
                read -p "$(pwd) $ " cmd # Solicită utilizatorului să introducă o comandă
                if [ "$cmd" = "exit" ]; then # Verifică dacă comanda este "exit"
                    logout "$username" # Apelează funcția logout pentru a deautentifica utilizatorul
                    break # Iese din bucla while
                else
                    eval "$cmd" # Execută comanda introdusă de utilizator
                fi
            done
            return # Iese din funcția autentificare
        else
            ((attempts++)) # Incrementează numărul de încercări
            if [ $attempts -eq $INCERCARI_MAXIME ]; then # Verifică dacă numărul maxim de încercări a fost atins
                read -p "Ați uitat parola? (da/nu): " am_uitat_parola? # Solicită utilizatorului să confirme dacă a uitat parola
                if [ "$am_uitat_parola?" == "da" ]; then
                    am_uitat_parola "$username" # Apelează funcția am_uitat_parola pentru a reseta parola
                else
                    echo "Revenire la meniul principal..." # Afișează un mesaj și revine la meniul principal
                fi
            else
                echo "Parolă incorectă! Mai aveți $((INCERCARI_MAXIME - attempts)) încercări." # Afișează un mesaj cu numărul de încercări rămase
            fi
        fi
    done
}

# Funcție pentru resetarea parolei
function am_uitat_parola() {
    local username=$1 # Stochează numele de utilizator în variabila locală "username"
    user_line=$(grep "^$username," users.csv) # Caută linia corespunzătoare utilizatorului în fișierul users.csv
    if [ -z "$user_line" ]; then # Verifică dacă linia este goală (utilizatorul nu există)
        echo "Utilizatorul $username nu există!" # Afișează un mesaj de eroare
        return # Iese din funcție
    fi

    # Citește întrebarea de securitate din fișierul users.csv
    intrebare_securitate=$(echo "$user_line" | cut -d',' -f4) # Extrage întrebarea de securitate din linia corespunzătoare utilizatorului

    read -p "$intrebare_securitate: " raspuns # Solicită utilizatorului să introducă răspunsul la întrebarea de securitate
    raspuns_corect=$(echo "$user_line" | cut -d',' -f5) # Extrage răspunsul corect la întrebarea de securitate din fișierul users.csv

    if [ "$raspuns" != "$raspuns_corect" ]; then # Verifică dacă răspunsul introdus este corect
        echo "Răspuns incorect!" # Afișează un mesaj de eroare dacă răspunsul este incorect
        return # Iese din funcție
    fi

    read -s -p "Introduceți noua parolă: " noua_parola # Solicită utilizatorului să introducă o nouă parolă (fără a afișa caracterele)
    echo # Afișează o linie nouă după citirea parolei

    # Extrage datele din linia utilizatorului, exceptând parola
    username=$(echo "$user_line" | cut -d',' -f1) # Extrage numele de utilizator
    email=$(echo "$user_line" | cut -d',' -f2) # Extrage adresa de email
    user_id=$(echo "$user_line" | cut -d',' -f6) # Extrage ID-ul unic al utilizatorului
    intrebare_securitate=$(echo "$user_line" | cut -d',' -f4) # Extrage întrebarea de securitate
    raspuns_securitate=$(echo "$user_line" | cut -d',' -f5) # Extrage răspunsul la întrebarea de securitate

    # Creează o nouă linie pentru utilizator cu noua parolă
    noua_linie="$username,$email,$noua_parola,$intrebare_securitate,$raspuns_securitate,$user_id,&timp" # Construiește noua linie cu datele actualizate

    # Suprascrie linia existentă din users.csv cu noua linie
    sed -i "s/^$username,.*/$noua_linie/" users.csv # Actualizează linia corespunzătoare utilizatorului în fișierul users.csv

    echo "Parola a fost actualizată cu succes!" # Afișează un mesaj de confirmare
}

#functie pentru logout
function logout() {
    local username=$1 # Stochează numele de utilizator în variabila locală "username"

    # Elimină utilizatorul din array-ul logged_in_users
    logged_in_users=("${logged_in_users[@]/$username}") # Elimină numele de utilizator din array-ul de utilizatori autentificați

    echo "Logout reușit pentru $username!" # Afișează un mesaj de confirmare
    cd "$HOME/DamianB" || return # Navighează înapoi în directorul "DamianB" sau iese din funcție dacă nu se poate
}

function vizualizare_rapoarte() {
    rapoarte_dir="$HOME/DamianB/proiect/rapoarte" # Construiește calea către directorul "rapoarte"
    if [ -d "$rapoarte_dir" ]; then # Verifică dacă directorul există
        echo "Rapoarte disponibile:" # Afișează un mesaj
        ls "$rapoarte_dir" # Listează conținutul directorului "rapoarte"
        read -p "Introdu numele raportului pentru a-l deschide (sau 'exit' pentru a ieși): " raport_nume # Solicită utilizatorului să introducă numele unui raport
        if [ "$raport_nume" == "exit" ]; then # Verifică dacă utilizatorul a introdus "exit"
            return # Iese din funcție
        elif [ -f "$rapoarte_dir/$raport_nume" ]; then # Verifică dacă fișierul raportului există
            cat "$rapoarte_dir/$raport_nume" # Afișează conținutul raportului
        else
            echo "Raportul $raport_nume nu există!" # Afișează un mesaj de eroare dacă raportul nu există
        fi
    else
        echo "Directorul rapoarte nu există!" # Afișează un mesaj de eroare dacă directorul "rapoarte" nu există
    fi
}

# Funcție pentru generarea raportului unui utilizator
# Funcție pentru generarea raportului unui utilizator
generare_raport() {
    read -p "Introdu numele de utilizator: " username # Solicită utilizatorului să introducă un nume de utilizator
    user_line=$(grep "^$username," users.csv) # Caută linia corespunzătoare utilizatorului în fișierul users.csv
    if [ -z "$user_line" ]; then # Verifică dacă linia este goală (utilizatorul nu există)
        echo "Utilizatorul $username nu există!" # Afișează un mesaj de eroare
        return # Iese din funcție
    fi

    user_data=$(grep "^$username," users.csv) # Obține datele utilizatorului din fișierul users.csv
    user_id=$(echo "$user_data" | cut -d',' -f6) # Extrage ID-ul unic al utilizatorului din datele utilizatorului
    home_dir="$HOME/DamianB/proiect/$username" # Construiește calea către directorul "home" al utilizatorului
    rapoarte_dir="$HOME/DamianB/proiect/rapoarte" # Construiește calea către directorul "rapoarte"

    # Creează directorul "rapoarte" dacă nu există
    mkdir -p "$rapoarte_dir" # Creează directorul "rapoarte" și toate directoarele părinte necesare

    (
        cd "$home_dir" || return # Navighează în directorul "home" al utilizatorului sau iese din funcție dacă nu se poate
        file_count=$(find . -type f | wc -l) # Numără numărul de fișiere din directorul "home" al utilizatorului
        dir_count=$(find . -type d | wc -l) # Numără numărul de directoare din directorul "home" al utilizatorului
        total_size=$(du -csh . | tail -1 | cut -f1) # Calculează dimensiunea totală a directoarelor și fișierelor din directorul "home" al utilizatorului

        # Construiește conținutul raportului
        raport="Raport pentru utilizatorul $username:
Număr de fișiere: $file_count
Număr de directoare: $dir_count
Dimensiune totală: $total_size"

        echo "$raport" > "$rapoarte_dir/raport_$username.txt" # Salvează raportul într-un fișier în directorul "rapoarte"
        echo "Raportul a fost generat în $rapoarte_dir/raport_$username.txt" # Afișează un mesaj de confirmare
    ) & # Execută blocul de cod într-un subproces în fundal
}

function meniu_admin() {
    while true; do
        clear # Curăță terminalul
        echo -e "${BIBlack}=====================================${NC}" # Afișează o linie de separare
        echo -e "        ${blink}MENIU ADMIN${NC}" # Afișează titlul meniului
        echo -e "${BIBlack}=====================================${NC}" # Afișează o linie de separare
        echo -e "${IGreen}1. Vizualizare users.csv${NC}" # Afișează opțiunea 1
        echo -e "${ICyan}2. Vizualizare rapoarte${NC}" # Afișează opțiunea 2
        echo -e "${IRed}3. Ieșire${NC}" # Afișează opțiunea 3
        echo -e "${BIBlack}=====================================${NC}" # Afișează o linie de separare
        echo -e "${BIGreen}" # Setează culoarea textului la verde intens
        read -p "Introdu alegerea ta [1-3]:" choice # Solicită utilizatorului să aleagă o opțiune
        echo -e "${NC}" # Resetează culoarea textului la valoarea implicită

        case $choice in
            1)
                # Afișează conținutul fișierului users.csv într-un tabel
                echo -e "${BIBlack}+------------------------+------------------------+------------------------+------------------------+------------------------+------------------------+------------------------+${NC}"
                echo "| Username              | Email                 | Parola                | Intrebare Securitate   | Raspuns Securitate    | ID Unic                | Data/Ora Inregistrare  |"
                echo -e "${BIBlack}+------------------------+------------------------+------------------------+------------------------+------------------------+------------------------+------------------------+${NC}"
                while IFS=',' read -r username email parola intrebare_securitate raspuns_securitate id_unic data_ora_inregistrare; do
                    printf "| %-22s | %-22s | %-22s | %-22s | %-22s | %-22s | %-22s |\n" "$username" "$email" "$parola" "$intrebare_securitate" "$raspuns_securitate" "$id_unic" "$data_ora_inregistrare"
                done < users.csv
                echo -e "${BIBlack}+------------------------+------------------------+------------------------+------------------------+------------------------+------------------------+------------------------+${NC}"
                ;;
            2)
                vizualizare_rapoarte ;; # Apelează funcția pentru a vizualiza rapoartele
            3)
                break ;; # Iese din bucla while
            *)
                echo "Alegere invalidă!" # Afișează un mesaj de eroare pentru o alegere invalidă
                ;;
        esac
        read -p "Apasă Enter pentru a continua..." # Pauză pentru a permite utilizatorului să vadă rezultatul
    done
}

#iesire + clear la terminal dupa iesire
function iesire_script() {
    clear # Curăță terminalul
    echo "Ieșire din meniu..." # Afișează un mesaj de ieșire
    exit 0 # Iese din script
}

#coduri pentru culori
# Reset
NC='\033[0m' # Text Reset

# Regular Colors
Black='\033[0;30m' # Black
Red='\033[0;31m' # Red
Green='\033[0;32m' # Green
Yellow='\033[0;33m' # Yellow
Blue='\033[0;34m' # Blue
Purple='\033[0;35m' # Purple
Cyan='\033[0;36m' # Cyan
White='\033[0;37m' # White

# Bold
BBlack='\033[1;30m' # Black
BRed='\033[1;31m' # Red
BGreen='\033[1;32m' # Green
BYellow='\033[1;33m' # Yellow
BBlue='\033[1;34m' # Blue
BPurple='\033[1;35m' # Purple
BCyan='\033[1;36m' # Cyan
BWhite='\033[1;37m' # White

# Underline
UBlack='\033[4;30m' # Black
URed='\033[4;31m' # Red
UGreen='\033[4;32m' # Green
UYellow='\033[4;33m' # Yellow
UBlue='\033[4;34m' # Blue
UPurple='\033[4;35m' # Purple
UCyan='\033[4;36m' # Cyan
UWhite='\033[4;37m' # White

# Background
On_Black='\033[40m' # Black
On_Red='\033[41m' # Red
On_Green='\033[42m' # Green
On_Yellow='\033[43m' # Yellow
On_Blue='\033[44m' # Blue
On_Purple='\033[45m' # Purple
On_Cyan='\033[46m' # Cyan
On_White='\033[47m' # White

# High Intensity
IBlack='\033[0;90m' # Black
IRed='\033[0;91m' # Red
IGreen='\033[0;92m'       # Green
IYellow='\033[0;93m'      # Yellow
IBlue='\033[0;94m'        # Blue
IPurple='\033[0;95m'      # Purple
ICyan='\033[0;96m'        # Cyan
IWhite='\033[0;97m'       # White

# Bold High Intensity
BIBlack='\033[1;90m'      # Black
BIRed='\033[1;91m'        # Red
BIGreen='\033[1;92m'      # Green
BIYellow='\033[1;93m'     # Yellow
BIBlue='\033[1;94m'       # Blue
BIPurple='\033[1;95m'     # Purple
BICyan='\033[1;96m'       # Cyan
BIWhite='\033[1;97m'      # White

# High Intensity backgrounds
On_IBlack='\033[0;100m'   # Black
On_IRed='\033[0;101m'     # Red
On_IGreen='\033[0;102m'   # Green
On_IYellow='\033[0;103m'  # Yellow
On_IBlue='\033[0;104m'    # Blue
On_IPurple='\033[0;105m'  # Purple
On_ICyan='\033[0;106m'    # Cyan
On_IWhite='\033[0;107m'   # White

blink='\033[5;107m'
blinkyellow='\033[5;103m'
underline='\033[4;107m'

# Golește ecranul
clear

# Afișează un mesaj de avertizare intermitent în culoarea galbenă
echo -e "${blinkyellow}!!!ATENȚIE!!!${NC}"

# Afișează un mesaj în culoarea roșie cu informații despre datele cu caracter personal
echo -e "\\n\\n ${IRed}Datele cu caracter personal furnizate vor fi folosite doar cu scopul înregistrării și autentificării în sistem! Aceste informații vor fi securizate și păstrate în siguranță de către creatorii proiectului."

# Solicită acordul utilizatorului
read -p "Sunteți de acord cu acest lucru ? (da/nu): " acord

# Resetează culoarea la normal
echo -e "${NC}"

# Verifică acordul utilizatorului
if \[ "$acord" != "da" \]; then
    echo "Operațiune anulată!"
    exit 1
fi

# Bucla principală a meniului
while true; do
    # Golește ecranul
    clear

    # Afișează meniul principal cu culori și efecte
    echo -e "${BIBlack}╔═══════════════════════════════════╗${NC}"
    echo -e "${BIBlack}║          ${blink}MENIU PRINCIPAL${NC}         ${BIBlack} ║${NC}"
    echo -e "${BIBlack}╠═══════════════════════════════════╣${NC}"
    echo -e "${BIBlack}║${IGreen} 1. Înregistrare utilizator nou    ${NC}${BIBlack}║${NC}"
    echo -e "${BIBlack}║${ICyan} 2. Autentificare ${NC}                 ${BIBlack}║${NC}"
    echo -e "${BIBlack}║${IYellow} 3. Logout ${NC}                        ${BIBlack}║${NC}"
    echo -e "${BIBlack}║${IPurple} 4. Generare raport ${NC}          ${BIBlack}     ║${NC}"
    echo -e "${BIBlack}║${IRed} 5. Ieșire ${NC}${BIBlack}                        ║${NC}"
    echo -e "${BIBlack}╚═══════════════════════════════════╝${NC}"

    # Schimbă culoarea la verde intensiv pentru citirea alegerii utilizatorului
    echo -e "${BIGreen}"
    read -p "Introdu alegerea ta [1-5]: " choice
    echo -e "${NC}" # Resetează culoarea la normal

    # Execută acțiunea corespunzătoare alegerii utilizatorului
    case $choice in
        1)
            inregistrare\_utilizator ;; # Apelează funcția pentru înregistrarea unui utilizator nou
        2)
            autentificare ;; # Apelează funcția pentru autentificarea unui utilizator
        3)
            logout ;; # Apelează funcția pentru delogarea unui utilizator
        4)
            generare\_raport ;; # Apelează funcția pentru generarea unui raport
        1015)
            meniu\_admin ;; # Apelează funcția pentru meniul de administrare (opțiune ascunsă)
        5)
            iesire\_script ;; # Apelează funcția pentru închiderea scriptului
        *)
            echo "Alegere invalidă!" # Mesaj în cazul unei alegeri invalide
            ;;
    esac

    # Pauză pentru a permite utilizatorului să vadă rezultatul operațiunii
    read -p "Apasă Enter pentru a continua..." 
done

# Golește ecranul după ieșirea din bucla principală
clear