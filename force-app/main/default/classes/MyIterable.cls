public class MyIterable implements Iterable<String> {
    private List<String> strings;

    // Constructor to initialize the list
    public MyIterable(List<String> strings) {
        this.strings = strings;
    }

    // Iterator method
    public Iterator<String> iterator() {
        return strings.iterator();
    }
}