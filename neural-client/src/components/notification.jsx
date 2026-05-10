import {IconCheck, IconX} from "@tabler/icons-react"
import {useEffect, useState} from "react";

const Notification = ({
    notification = {}
}) => {
    const {message, type = "hide"} = notification
    const [show, setShow] = useState(false)

    useEffect(() => {
        setShow(true)
        setTimeout(() => {
            setShow(false)
        }, 5000)
    }, [message, type])

    if (!show || type === "hide") return null
    return (
        <div className={`notification ${type}`}>
            {type === 'success' ? (
                <IconCheck size={20} />
            ) : (
                <IconX size={20} />
            )}
            <span>{message}</span>
        </div>
    );
};

export default Notification;