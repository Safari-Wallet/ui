`use strict`;

// For older browsers:
typeof window.addEventListener === `undefined` && (window.addEventListener = (e, cb) => window.attachEvent(`on${e}`, cb));

window.addEventListener(`load`, () => {

    const $ = (id) => document.getElementById(id);

    let logs = [];
    let fetching = false;

    const fetchLogs = () => {
        const date = new Date();
        $(`time`).innerText = `${date.getHours()}:${date.getMinutes()}:${date.getSeconds()}`;
        if (fetching === false) {
            fetching = true;
            const xhr = new XMLHttpRequest();
            xhr.onload = (data) => {
                try {
                    logs = JSON.parse(data.srcElement.response).logs;
                    const numLogs = logs.length;
                    const previous = $(`tbody`).innerHTML;
                    $(`tbody`).innerHTML = ``;
                    for (let i = 0; i < numLogs; i++) {
                        const tr = document.createElement(`tr`);

                        const tdTime = document.createElement(`td`);
                        const utc = new Date(logs[i].timestamp);
                        tdTime.innerText = `${utc.getHours()}:${utc.getMinutes()}:${utc.getSeconds()}`;
                        tr.appendChild(tdTime);

                        const tdSender = document.createElement(`td`);
                        tdSender.innerText = logs[i].senderContext;
                        tr.appendChild(tdSender);

                        switch (logs[i].senderContext) {
                            case `popup.js`:
                                tdSender.style.color = `lightskyblue`;
                                break;
                            case `content.js`:
                                tdSender.style.color = `orange`;
                                break;
                            case `background.js`:
                                tdSender.style.color = `yellow`;
                                break;
                            default:
                                tdSender.style.color = `red`;
                        }

                        const tdMessage = document.createElement(`td`);
                        tdMessage.innerText = logs[i].message;
                        tr.appendChild(tdMessage);

                        $(`tbody`).appendChild(tr);
                    }
                    if (previous !== $(`tbody`).innerHTML && !!$(`checkbox`).checked) {
                        $(`table`).scrollTop = $(`table`).scrollHeight;
                    }
                    fetching = false;
                } catch (e) {
                    console.log(`Error`, e.message);
                    // TODO handle
                }
            }
            xhr.open(`GET`, `http://localhost:8081/json`);
            xhr.send();
        }
    };

    $(`button`).addEventListener(`click`, () => {
        const xhr = new XMLHttpRequest();
        xhr.onload = () => fetchLogs();
        xhr.open(`POST`, `http://localhost:8081/clear`);
        xhr.send();
    });

    fetchLogs();
    setInterval(fetchLogs, 1000);

});
