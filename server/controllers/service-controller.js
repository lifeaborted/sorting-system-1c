const {WebSocketServer} = require('ws')
const jwt = require('jsonwebtoken');

class ServiceController
{
    constructor()
    {
        this.socket = new WebSocketServer({ noServer: true })
    }

    async authenticate(request, socket, head)
    {
        try
        {
            const token = request.headers?.authorization?.split(" ")[1]

            if(!token)
            {
                socket.write('HTTP/1.1 401 Unauthorized\r\n\r\n');
                socket.destroy();
                return;
            }
            jwt.verify(token, process.env.JWT_PASSWORD_CODE)

            this.socket.handleUpgrade(request, socket, head, () => {})
        }
        catch(e)
        {
            socket.write('HTTP/1.1 401 Unauthorized\r\n\r\n')
            socket.destroy()
        }

    }

    async broadcast(message)
    {
        for(const client of this.socket.clients)
        {
            if (client.readyState !== WebSocket.OPEN) continue
            client.send(message)
        }
    }
}

module.exports = new ServiceController()