namespace entanglement {
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Intrinsic;

    operation NonEntanglementTest(a: Qubit, b: Qubit): Unit {
        SetQubitState(One, a);
        SetQubitState(Zero, b);
        R(PauliX, 1.0, a);
    }

    operation EntanglementTest(a: Qubit, b: Qubit): Unit {
        SetQubitState(One, a);
        SetQubitState(Zero, b);
        R(PauliX, 1.0, a);
        CNOT(a, b);
    }

    operation SetQubitState(desired : Result, target : Qubit) : Unit {
        if (desired != M(target)) {
            X(target);
        }
    }

    operation RunTest(count : Int, test: ((Qubit, Qubit) => Unit)) : (Int, Int) {
        mutable numOnes = 0;
        mutable disagreement = 0;
        using ((q0, q1) = (Qubit(), Qubit())) {

            for (i in 1..count) {
                test(q0, q1);
                let res = M(q0);
                let res2 = M(q1);

                if (res == One) {
                    set numOnes += 1;
                }
                if (res != res2) {
                    set disagreement += 1;
                }
            }

            SetQubitState(Zero, q0);
            SetQubitState(Zero, q1);
        }
        return (numOnes, disagreement);
    }

    operation TestGate(testName: String, count : Int, op : ((Qubit, Qubit) => Unit)) : Unit {
        let (numOnes, disagreement) = RunTest(count, op);
        // Return number of times we saw a |0> and number of times we saw a |1>
        Message(testName + ": Test results (# of 0s, # of 1s, # of disagreements): " + IntAsString(count - numOnes) + ", " + IntAsString(numOnes) + ", " + IntAsString(disagreement));
    }

    @EntryPoint()
    operation RunTests(): Unit {
        let count = 1000;
        TestGate("Not entangled", count, NonEntanglementTest);
        TestGate("Entangled", count, EntanglementTest);
    }
}
