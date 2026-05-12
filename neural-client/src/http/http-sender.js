import axios from "axios"

class HttpSender
{
    protocol = "http"
    baseURL = ""
    path = "/neural/upload/"

    constructor()
    {
        this.baseURL = localStorage.getItem('base-url') || "localhost:5001"
    }

    getProtocol()
    {
        return this.protocol
    }

    getBaseURL()
    {
        return this.baseURL
    }

    getPath()
    {
        return this.path
    }

    setBaseURL(baseURL)
    {
        localStorage.setItem('base-url', baseURL)
        this.baseURL = baseURL
    }

    async SendImage(image)
    {
        return new Promise((resolve, reject) => {
            const formData = new FormData()
            formData.append('file', image)

            axios.post(`${this.protocol}://${this.baseURL}${this.path}`, formData, {
                headers: {
                    'Content-Type': 'multipart/form-data',
                },
            }).then(() => resolve()).catch(err=>{reject(err)})
        })
    }
}

export default new HttpSender