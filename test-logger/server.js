const express = require(`express`);
const cors = require(`cors`);

let responseData = {
    logs: [],
};

const app = express();

app.use(express.json());

app.use(cors({
    credentials: true,
    origin: `*`,
}));

app.use('/', express.static(`public`));

app.get(`*`, (req, res) => {
    if (req.url !== `/`) {
        switch (req.url) {
            case `/json`:
                res.set(`Content-Type`, `application/json`);
                res.writeHead(200);
                res.end(JSON.stringify(responseData));
                break;
            default:
                res.set(`Content-Type`, `application/json`);
                res.writeHead(404);
                res.end(JSON.stringify({
                    error: `Not found.`,
                }));
        }
    }
});

app.post(`/add`, (req, res) => {
    res.set(`Content-Type`, `application/json`);
    const message = req.query[`message`];
    const senderContext = req.query[`sender`];
    if (typeof message !== `undefined` && typeof senderContext !== `undefined`) {
        const timestamp = Date.now();
        if (typeof message !== `string`) {
            try {
                message = JSON.stringify(message);
            } catch (e) {}
        }
        responseData.logs.push({
            message,
            senderContext,
            timestamp,
        });
        res.writeHead(200);
        res.end(JSON.stringify({
            error: false,
            message: `Success.`,
        }));
    } else {
        res.writeHead(500);
        res.end(JSON.stringify({
            error: true,
            message: `Unable to add log.`,
        }));
    }
});

app.post(`/clear`, (req, res) => {
    res.set(`Content-Type`, `application/json`);
    responseData.logs = [];
    res.writeHead(200);
    res.end(JSON.stringify({
        error: false,
        message: `Success.`,
    }));
});

const startup = () => console.log(`Listening for requests at http://localhost:8081`);

app.listen(8081, startup);
