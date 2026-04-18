module.exports = function (req, res, next)
{
    if (req.method === "OPTIONS")
    {
        next()
    }

    try
    {
        const key = req.headers.authorization
        if (key !== process.env.SCANNER_API_KEY)
        {
            return res.status(401).json({message: "Not authorized"})
        }
        next()
    }
    catch (e)
    {
        res.status(401).json({message: "Not authorized"})
    }
};
