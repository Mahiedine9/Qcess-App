package univ.lille.module_notification.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class DoorEventMessage {

    private String type;      // e.g. "EVENT"
    private String state;     // e.g. "OPENED", "LOCKED", ...
    private String deviceId;  // e.g. "DOOR_01"
    private long timestamp;   // epoch millis
}
