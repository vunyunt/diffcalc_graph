rm -rf ../gen
mkdir ../gen
protoc -I=. --dart_out=../gen ./*.proto google/protobuf/any.proto