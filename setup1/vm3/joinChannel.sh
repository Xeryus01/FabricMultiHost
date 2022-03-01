export CORE_PEER_TLS_ENABLED=true
export ORDERER_CA=${PWD}/../../artifacts/channel/crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
export PEER0_ORG3_CA=${PWD}/../../artifacts/channel/crypto-config/peerOrganizations/org3.example.com/peers/peer0.org3.example.com/tls/ca.crt
export FABRIC_CFG_PATH=${PWD}/../../artifacts/channel/config/

export CHANNEL_NAME=mychannel

# ganti ORD_IP (IP Orderer) sesuai dengan IP pada VM orderer yang digunakan
export ORD_IP=localhost
export ORD_PORT=7050

# Fungsi untuk export variable sesuai dengan Peer0Org3
setGlobalsForPeer0Org3() {
    export CORE_PEER_LOCALMSPID="Org3MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_ORG3_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/../../artifacts/channel/crypto-config/peerOrganizations/org3.example.com/users/Admin@org3.example.com/msp
    export CORE_PEER_ADDRESS=localhost:11051

}

fetchChannelBlock() {
    # Menghapus semua channel artifacts yang masih tersisa sebelumnya
    rm -rf ./channel-artifacts/*
    setGlobalsForPeer0Org3

    # command untuk mendapatkan channel yang sudah dibuat "peer channel fetch ..."
    # channel cukup dibuat pada satu VM (pada kasus ini, channel dibuat pada VM1, sedangkan VM lain hanya perlu melakukan fetching channel)
    peer channel fetch 0 ./channel-artifacts/$CHANNEL_NAME.block -o ${ORD_IP}:${ORD_PORT} \
        --ordererTLSHostnameOverride orderer.example.com \
        -c $CHANNEL_NAME --tls --cafile $ORDERER_CA
}

# Fungsi untuk bergabung dengan channel
joinChannel() {
    setGlobalsForPeer0Org3

    # command untuk bergabung dengan channel "peer channel join ..."
    peer channel join -b ./channel-artifacts/$CHANNEL_NAME.block

}

# Fungsi untuk update channel setelah bergabung dengan channel
updateAnchorPeers() {
    setGlobalsForPeer0Org3

    # command untuk update channel setelah bergabung dengan channel "peer channel update ..."
    peer channel update -o ${ORD_IP}:${ORD_PORT} --ordererTLSHostnameOverride orderer.example.com \
        -c $CHANNEL_NAME -f ./../../artifacts/channel/${CORE_PEER_LOCALMSPID}anchors.tx \
        --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA

}

# Eksekusi semua fungsi di atas
fetchChannelBlock
joinChannel
updateAnchorPeers