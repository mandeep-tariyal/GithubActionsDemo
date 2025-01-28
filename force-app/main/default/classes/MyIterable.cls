public class MyIterable implements Iterable<String> {
    private List<String> strings;

    // Constructor to initialize the list
    public MyIterable(List<String> strings) {
        this.strings = strings;
        System.debug('This.string'+this.strings);
    }

    // Iterator method
    public Iterator<String> iterator() {
        return strings.iterator();
    }
}