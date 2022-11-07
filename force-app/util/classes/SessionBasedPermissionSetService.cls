public class SessionBasedPermissionSetService {
    public static void activatePermissionSetForCurrentUser(String permissionSetName) {
        Flow.Interview flow = new Flow.Interview.Session_Based_Permission_Set_Actions(
            new Map<String, Object> {
                'actionType' => 'Activate',
                'permissionSetName' => permissionSetName
            }
        );
        flow.start();
    }

    public static void deactivatePermissionSetForCurrentUser(String permissionSetName) {
        Flow.Interview flow = new Flow.Interview.Session_Based_Permission_Set_Actions(
            new Map<String, Object> {
                'actionType' => 'Deactivate',
                'permissionSetName' => permissionSetName
            }
        );
        flow.start();
    }

}