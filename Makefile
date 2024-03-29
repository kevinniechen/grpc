HOST_SYSTEM = $(shell uname | cut -f 1 -d_)
SYSTEM ?= $(HOST_SYSTEM)
CXX = g++
CPPFLAGS += `pkg-config --cflags protobuf grpc`
CXXFLAGS += -std=c++11
ifeq ($(SYSTEM),Darwin)
    LDFLAGS += -L/usr/local/lib `pkg-config --libs protobuf grpc++`\
	                  -lgrpc++_reflection\
			             -ldl
    else
    LDFLAGS += -L/usr/local/lib `pkg-config --libs protobuf grpc++`\
	                  -Wl,--no-as-needed -lgrpc++_reflection -Wl,--as-needed\
			             -ldl
    endif
    PROTOC = protoc
    GRPC_CPP_PLUGIN = grpc_cpp_plugin
    GRPC_CPP_PLUGIN_PATH ?= `which $(GRPC_CPP_PLUGIN)`

PROTOS_PATH = protos/

vpath %.proto $(PROTOS_PATH)

all: client server 

client: key_exchange.pb.o key_exchange.grpc.pb.o client.o
	    $(CXX) $^ $(LDFLAGS) -o $@

server: key_exchange.pb.o key_exchange.grpc.pb.o server.o
	    $(CXX) $^ $(LDFLAGS) -o $@

%.grpc.pb.cc: %.proto
	    $(PROTOC) -I $(PROTOS_PATH) --grpc_out=. --plugin=protoc-gen-grpc=$(GRPC_CPP_PLUGIN_PATH) $<

%.pb.cc: %.proto
	    $(PROTOC) -I $(PROTOS_PATH) --cpp_out=. $<

clean:
	    rm -f *.o *.pb.cc *.pb.h client server

