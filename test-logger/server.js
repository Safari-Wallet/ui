const dotenv = require(`dotenv`);
const process = require(`process`);
const express = require(`express`);
const cors = require(`cors`);

dotenv.config();

const PORT = process.env.PORT;
const VERBOSE = process.env.VERBOSE;

let responseData = {
    logs: [],
};

const app = express();

app.use(express.json());

app.use(cors({
    credentials: true,
    origin: `*`,
}));

app.get(`*`, (req, res) => {
    res.set(`Content-Type`, `application/json`);
    switch (req.url) {
        case `/`:
            res.writeHead(200);
            res.end(JSON.stringify(responseData));
            break;
        default:
            res.writeHead(404);
            res.end(JSON.stringify({
                error: `Not found.`,
            }));
    }
});

app.post(`/add`, (req, res) => {
    res.set(`Content-Type`, `application/json`);
    const message = req.query[`message`];
    const senderContext = req.query[`sender`];
    if (typeof message !== `undefined` && typeof senderContext !== `undefined`) {
        const timestamp = Date.now();
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
        !!VERBOSE && (console.log(`New log from ${senderContext}: "${message}" @ ${timestamp}`));
    } else {
        res.writeHead(500);
        res.end(JSON.stringify({
            error: true,
            message: `Unable to add log.`,
        }));
        !!VERBOSE && (console.log(`Failed to add a log.`));
    }
});

const startup = () => console.log(`Listening for requests at http://localhost:${PORT}`);

app.listen(PORT, startup);
