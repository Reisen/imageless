// This Screen allows registration, the reason we do this instead of
// sharing the login screen/components is the goal to display information
// about the project during registration. This means the screens are more
// dissimilar than just a pair of forms.

import React            from 'react';
// import { User as user } from '../../api/types';
import { connect }      from 'react-redux';
import { State }        from '../../store';
import { History }      from 'history'
import { registerUser } from '../../store/users';

// Components
import NavigationBar    from '../../components/NavigationBar';
import TextInput        from '../../components/TextInput';
import Button           from '../../components/Button';
import styles           from './UserRegister.module.css';


interface Props {
    registerUser: (email: string, password: string) => Promise<Response>;
    username:     string;
    history:      History;
}

const headerLinks = [
    {name: 'Login', path: ''},
    {name: 'Register', path: ''},
];

const UserRegister = (props: Props) => {
    const [email, setEmail]       = React.useState('');
    const [password, setPassword] = React.useState('');
    const [waiting, setWaiting]   = React.useState(false);
    const [error, setError]       = React.useState('');

    // Handle Registration Clicks
    const handleCreate = async () => {
        setWaiting(true);
        const result = await props.registerUser(email, password)
        if (result.ok) props.history.push('/');
        else {
            setWaiting(false);
            setError('Registration Failed');
        }
    };

    return (
        <div className="Page">
            <NavigationBar links={headerLinks} username={props.username} />
            <div className={styles.Root}>
                <div className={styles.RegisterForm}>
                    <TextInput
                        onChange={e => setEmail(e.target.value)}
                        placeholder="Email"
                        value={email}
                    />

                    <TextInput
                        onChange={e => setPassword(e.target.value)}
                        placeholder="Password"
                        type="password"
                        value={password}
                    />

                    <Button disabled={waiting} onClick={handleCreate}>
                        Create My Account
                    </Button>

                    { error &&
                        <span>{error}</span>
                    }
                </div>
            </div>
        </div>
    );
};

const mapState = (state: State) => ({
    username: state.user.username
});

const mapDispatch = {
    registerUser
};

export default connect(mapState, mapDispatch)(UserRegister);
