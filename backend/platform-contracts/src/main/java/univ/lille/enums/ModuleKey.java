package univ.lille.enums;
// à modifier en fonction des modules de l'application
public enum ModuleKey {
    ACCESS(true),
    MAINTENANCE(false),
    HISTORIC(true),
    SUPPORT(false),
    ORGANISATION(true),
    ROOMBOOKING(false),
    NOTIFICATIONS(true);
    private final boolean mandatory;

    ModuleKey(boolean mandatory) {
        this.mandatory = mandatory;
    }

    public boolean isMandatory() {
        return mandatory;
    }

}
