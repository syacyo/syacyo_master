#!/bin/bash

#othello
#2019/9/4
#auther syacyo
#ver 0.01

#定数定義
readonly STATE_NEWTRAL=0    #マス未配置
readonly STATE_WHITE=1      #マス白
readonly STATE_BLACK=2      #マス黒
readonly CURSOL_NOT_EXIST=0 #カーソルなし
readonly CURSOL_EXIST=1     #カーソルあり

#グローバル変数定義
curturn=$STATE_WHITE    #現在のターン 
declare -A state        #各マスの状態(未配置：STATE_NEWTRAL 白：STATE_WHITE 黒：STATE_BLACK)
curi=0                  #カーソル位置(行)
curj=0                  #カーソル位置(列)
revcount=0              #$1の方向への反転色の数
isreversable=0          #$1の方向に自色があるかどうか
chki=0                  #現在のチェック位置(行)
chkj=0                  #現在のチェック位置(列)

#初期化
initialize(){
    #各テーブルをクリア
    for i in {0..7}
    do  
        for j in {0..7}
        do  
            state[${i}, ${j}]=$STATE_NEWTRAL
        done
    done
    #各マス初期化
    state[3, 3]=$STATE_WHITE
    state[3, 4]=$STATE_BLACK
    state[4, 3]=$STATE_WHITE
    state[4, 4]=$STATE_BLACK
}

#カーソル位置を更新する
calc_cursol(){
    #カーソル移動先を計算
    case "$1" in
    "j"|$'\x1b\x5b\x41')#上
        if [ "$curi" -gt 0 ]; then
            curi=$((curi - 1))
        fi
        ;;
    "k"|$'\x1b\x5b\x42')#下
        if [ "$curi" -lt 7 ]; then
            curi=$((curi + 1))
        fi
        ;;
    "h"|$'\x1b\x5b\x44')#左
        if [ "$curj" -gt 0 ]; then
            curj=$((curj - 1))
        fi
        ;;
    "l"|$'\x1b\x5b\x43')#右
        if [ "$curj" -lt 7 ]; then 
            curj=$((curj + 1))      
        fi  
        ;;
    esac
}

#次のチェック位置を更新($1 [上:8] [下:2] [左:4] [右:6] [左上:7] [右上:9] [左下:1] [右下:3])
calcnextcell(){
    case "$1" in
    8)#上
        chki=$((chki - 1))
        ;;
    2)#下
        chki=$((chki + 1))
        ;;
    4)#左
        chkj=$((chkj - 1))
        ;;
    6)#右
        chkj=$((chkj + 1))
        ;;
    7)#左上
        chki=$((chki - 1))
        chkj=$((chkj - 1))
        ;;
    9)#右上
        chki=$((chki - 1))
        chkj=$((chkj + 1))
        ;;
    1)#左下
        chki=$((chki + 1))
        chkj=$((chkj - 1))
        ;;
    3)#右下
        chki=$((chki + 1))
        chkj=$((chkj + 1))
        ;;
    esac
}

#アイコンを置けるかどうかのチェック($1 [上:8] [下:2] [左:4] [右:6] [左上:7] [右上:9] [左下:1] [右下:3])
revercecheck(){
    #次のチェック位置取得
    calcnextcell $1
    #範囲チェック
    if [ "$chki" -lt 0  ] || [ "$chki" -gt 7  ]; then
        return
    fi
    if [ "$chkj" -lt 0  ] || [ "$chkj" -gt 7  ]; then
        return
    fi
    #反転チェック
    for i in {0..7}
    do  
        for j in {0..7}
        do
            if [ "${chki}" -eq $i ] && [ "${chkj}" -eq $j ]; then
                #チェック位置
                if [ "${state[${chki}, ${chkj}]}" -eq $curturn ]; then
                    #チェック位置が自色だった場合はフラグを立てる
                    isreversable=1
                    return
                elif [ "${state[${chki}, ${chkj}]}" -eq $STATE_NEWTRAL ]; then
                    #チェック位置が未配置だった場合はチェック終了
                    return
                else
                    #チェック位置が自色でも未配置でもない(=反転色)だった場合は次のマスをチェック
                    revcount=$((revcount + 1))
                    revercecheck $1
                fi  
            fi
        done
    done
}

#アイコン反転($1 [上:8] [下:2] [左:4] [右:6] [左上:7] [右上:9] [左下:1] [右下:3])
reverceexecute(){
    #次のチェック位置取得
    calcnextcell $1
    #範囲チェック
    if [ "$chki" -lt 0  ] || [ "$chki" -gt 7  ]; then
        return
    fi
    if [ "$chkj" -lt 0  ] || [ "$chkj" -gt 7  ]; then
        return
    fi
    #反転チェック
    for i in {0..7}
    do  
        for j in {0..7}
        do
            if [ "${chki}" -eq $i ] && [ "${chkj}" -eq $j ]; then
                #チェック位置
                if [ "${state[${chki}, ${chkj}]}" -eq $curturn ]; then
                    #念の為自アイコンを反転させないように区別
                    return
                elif [ "${state[${chki}, ${chkj}]}" -eq $STATE_NEWTRAL ]; then
                    #念の為未配置アイコンを反転させないように区別
                    return
                else
                    #チェック位置が自色でも未配置でもない(=反転色)だった場合は反転して次のマスをチェック
                    if [ "$curturn" -eq $STATE_WHITE ]; then
                        state[${chki}, ${chkj}]=$STATE_WHITE
                    else
                        state[${chki}, ${chkj}]=$STATE_BLACK
                    fi
                    revcount=$((revcount - 1))
                    if [ "$revcount" -lt 0 ]; then
                        return
                    else
                        reverceexecute $1
                    fi
                fi  
            fi
        done
    done
}

#白または黒アイコンの配置
addicon(){
    if [ "${state[${curi}, ${curj}]}" -ne $STATE_NEWTRAL ]; then
        #既に駒が置かれている場所を決定した場合
        echo "そこには置けません"
        return
    fi
    local isreversabletotal=0
    local checkparam=(1 2 3 4 5 6 7 8 9)
    chki=$curi
    chkj=$curj
    revcount=0
    isreversable=0
    for param in ${checkparam[@]}
    do
        chki=$curi
        chkj=$curj
        revcount=0
        isreversable=0
        revercecheck $param    #現在のカーソル位置にアイコンが置けるかどうかチェック
        if [ "$isreversable" -ne 0 ] && [ "$revcount" -gt 0 ]; then
            #アイコンが置ける場合反転出来る数だけ反転する
            chki=$curi
            chkj=$curj
            reverceexecute $param    #現在のカーソル位置にアイコンが置ける場合、反転する
            revcount=0
            isreversable=0
            isreversabletotal=$((isreversabletotal + 1))
        fi
    done
    if [ "$isreversabletotal" -gt 0 ]; then
        #アイコンが置けた場合はカーソル位置を自アイコンに更新してターン変更
        state[${curi}, ${curj}]=$curturn
        #ターン交代
        if [ "$curturn" -eq $STATE_WHITE ]; then
            curturn=$STATE_BLACK
        else
            curturn=$STATE_WHITE
        fi
    else
        echo "そこには置けません"
    fi
    return
}

#自ターンの駒が置けるかどうかチェック
ismyturnadable=0
addablecheck(){
    ismyturnadable=0
    for i in {0..7}
    do
        for j in {0..7}
        do
            if [ "${state[$i, $j]}" -eq $STATE_NEWTRAL ]; then
                local checkparam=(1 2 3 4 5 6 7 8 9)
                for param in ${checkparam[@]}
                do
                    chki=$i
                    chkj=$j
                    revcount=0
                    isreversable=0
                    revercecheck $param    #現在のカーソル位置にアイコンが置けるかどうかチェック
                    if [ "$isreversable" -ne 0 ] && [ "$revcount" -gt 0 ]; then
						ismyturnadable=1 #1箇所でも置ける場所があった場合にフラグを立てる
                        return
					fi
                done
            fi
        done
    done
}
                                                                                                     
#オセロメインスレッド
main(){
    local notaddturnnum=0 #ターンに駒が置けなくてスキップした連続回数
    while :
    do
        #マスと白黒アイコンとカーソルの描画
        for i in {0..7}
        do
            #echo "-------------------------"
            for j in {0..7}
            do
                case "${state[$i, $j]}" in
                $STATE_NEWTRAL)
                    #未配置のマスの処理
                    if [ "$curi" -eq $i ] && [ "$curj" -eq $j ]; then
                        #カーソル位置だった場合はカーソルアイコン描画
                        echo -n "|*"
                    else
                        #カーソル位置ではない場合は未配置
                        echo -n "| "
                    fi
                    ;;
                $STATE_WHITE)
                    #白アイコンのマスの処理
                    echo -n "|o"
                    ;;
                $STATE_BLACK)
                    #黒アイコンのマスの処理
                    echo -n "|x"
                    ;;
                esac
            done
            echo "|"
        done
        if [ "$curturn" -eq $STATE_WHITE ]; then
            echo "現在のターン=o"
        else
            echo "現在のターン=x"
        fi
        #自ターンの駒が置けるマスがあるかどうかチェック
        addablecheck
        if [ "$ismyturnadable" -eq 1 ]; then
            #自ターンの駒が入力可能な場合
            notaddturnnum=0
            #カーソル位置を選択させるための入力待ち
            read -n 1 -p "マスを選択して下さい([上:j/↑] [下:k/↓] [左:h/←] [右:l/→] [決定:d] [終了:q]) > " input
            if [[ $input == $'\x1b' ]]; then
                #方向キーの場合、続きの文字コードも受け取る
                read -r -n2 -s rest
                input+="$rest"
            fi
            clear
            case "${input}" in
            "j"|"k"|"h"|"l"|$'\x1b\x5b\x41'|$'\x1b\x5b\x42'|$'\x1b\x5b\x43'|$'\x1b\x5b\x44')
                calc_cursol $input
                ;;
            "d")
                addicon
                ;;
            "q")
                exit
                ;;
            *)
                echo "入力エラー"
            esac
        else
            #自ターンの駒が置けるマスが無い場合。連続スキップ数を加算
            notaddturnnum=$((notaddturnnum + 1))
			echo "駒を置ける場所がありません"
            if [ "$notaddturnnum" -lt 2 ]; then
                #ターン交代
                if [ "$curturn" -eq $STATE_WHITE ]; then
                    curturn=$STATE_BLACK
                else
                    curturn=$STATE_WHITE
                fi
            else
                #両ターンとも置ける場所が無いので終了
                echo "ゲーム終了"
				return
            fi
        fi
    done
}

clear
initialize
main

