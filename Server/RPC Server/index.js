var server = require('http').createServer()
var port = process.env.PORT || 8900;

let player1Name = "1"
let player2Name = "2"

// Show in witch port the server is listening 
// Should make the port variable?
server.listen(port, () => {
    console.log('Server listening at port %d', port)
  })

function User(socket) {
    var self = this
    this.socket = socket
    this.name = ""
    this.chat = {}
    console.log("Connected user")

    this.socket.on("sendMessage", function(from, message) {
        self.chat.sendMessageToUser(from, message)
    })

    this.socket.on("sendRemoveLetter", function(from, letter) {
        self.chat.removeLetter(from, letter)
    })

    this.socket.on("sendAddLetter", function(from, letter) {
        self.chat.addLetter(from, letter)
    })

    this.socket.on("sendRequestToConfirm", function(from) {
        self.chat.requestToConfirm(from)
    })

    this.socket.on("sendResponseToConfirm", function(from, response, lettersToRemove) {
        self.chat.responseToConfirm(from, response, lettersToRemove)
    })

    this.socket.on("sendSortLetter", function(from, letter, letterIndex) {
        self.chat.sortLetter(from, letter, letterIndex)
    })

    this.socket.on("sendCurrentUserWon", function(from) {
        self.chat.userWon(from)
    })

    this.socket.on("sendRestartMatch", function() {
        self.chat.restartMatch()
    })

    this.socket.on("disconnect", () => {
        // Remove user or finish game?
        self.chat.removeUser(socket)
    })
}

User.prototype.joinChat = function(chat) {
    this.chat = chat
}

function Chat() {
    this.io = require('socket.io')(server)
    this.user1 = null
    this.user2 = null
    this.addHandlers()
}

Chat.prototype.addHandlers = function() {
    var chat = this

    this.io.sockets.on("connection", function(socket) {
        console.log("connecting user")
        chat.addUser(new User(socket))
    })
}

Chat.prototype.addUser = function(user) {
    console.log("Adding user")

    if (this.user1 === null) {
        this.user1 = user
        this.user1["chat"] = this
        this.user1["name"] = player1Name
        this.user1.socket.username = player1Name
        this.user1.socket.emit("name", player1Name)
    } else if (this.user2 === null) {
        this.user2 = user
        this.user2["chat"] = this
        this.user2["name"] = player2Name
        this.user2.socket.username = player2Name
        this.user2.socket.emit("name", player2Name)
    }

    if (this.user1 !== null && this.user2 !== null) {
        this.startChat()
    }
}

Chat.prototype.removeUser = function(socket) {
    console.log("Removing user")
    console.log(socket.username)
    if (socket.username === player1Name) {
        this.user1 = null
        if (this.user2 !== null) {
            this.user2.socket.emit("otherUserResign")
        }
    } else if (socket.username === player2Name) {
        this.user2 = null
        if (this.user1 !== null) {
            this.user1.socket.emit("otherUserResign")
        }
    }
}

Chat.prototype.sendMessageToUser = function(from, message) {
    console.log("Received message on server")
    if (this.user1["name"] === from) {
        this.user2.socket.emit("receiveMessage", message)
    } else if (this.user2["name"] === from) {
        this.user1.socket.emit("receiveMessage", message)
    }
}

Chat.prototype.startChat = function() {
    console.log("Starting Chat")
    this.user1.socket.emit("startChat", player1Name)
    this.user2.socket.emit("startChat", player2Name)
}

Chat.prototype.removeLetter = function(from, letter) {
    if (this.user1["name"] === from) {
        this.user2.socket.emit("removeLetter", letter)
    } else if (this.user2["name"] === from) {
        this.user1.socket.emit("removeLetter", letter)
    }
}

Chat.prototype.addLetter = function(from, letter) {
    if (this.user1["name"] === from) {
        this.user2.socket.emit("addLetter", letter)
    } else if (this.user2["name"] === from) {
        this.user1.socket.emit("addLetter", letter)
    }
}

Chat.prototype.requestToConfirm = function(from) {
    if (this.user1["name"] === from) {
        this.user2.socket.emit("requestToConfirm")
    } else if (this.user2["name"] === from) {
        this.user1.socket.emit("requestToConfirm")
    }
}

Chat.prototype.responseToConfirm = function(from, response, lettersToRemove) {
    if (this.user1["name"] === from) {
        this.user2.socket.emit("responseToConfirm", response, lettersToRemove)
    } else if (this.user2["name"] === from) {
        this.user1.socket.emit("responseToConfirm", response, lettersToRemove)
    }
}

Chat.prototype.sortLetter = function(from, sortLetter, letterIndex) {
    if (this.user1["name"] === from) {
        this.user2.socket.emit("sortLetter", sortLetter, letterIndex)
    } else if (this.user2["name"] === from) {
        this.user1.socket.emit("sortLetter", sortLetter, letterIndex)
    }
}

Chat.prototype.userWon = function(from) {
    if (this.user1["name"] === from) {
        if (this.user2 !== null) {
            this.user2.socket.emit("otherUserWon")
        }
    } else if (this.user2["name"] === from) {
        if (this.user1 !== null) {
        this.user1.socket.emit("otherUserWon")
        }
    }
}

Chat.prototype.restartMatch = function() {
    this.user1.socket.emit("restartMatch")
    this.user2.socket.emit("restartMatch")
}

// Start chat server
var chat = new Chat()
