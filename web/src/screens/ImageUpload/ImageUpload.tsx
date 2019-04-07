import React, { useState, useRef } from 'react';
import { Image as image }          from '../../api/types';
import { State }                   from '../../store';
import { connect }                 from 'react-redux';
import { getImages }               from '../../store/images';
import { uploadImage }             from '../../api/images';
import { History }                 from 'history'

import Attribute                   from '../../components/Attribute';
import Button                      from '../../components/Button';
import TextInput                   from '../../components/TextInput';
import NavigationBar               from '../../components/NavigationBar';
import ImageInput                  from './components/ImageInput';
import styles                      from './ImageUpload.module.css';


interface Props {
    images:   image[];
    username: string;
    history:  History;
}

const headerLinks = [
    {name: 'Single Image', path: '/my/upload'},
    {name: 'Zip Upload',   path: '/my/upload/zip'}
];

const Image = (props: Props) => {
    // Create State Stuff
    const [tags, setTags]   = useState<string[]>([]);
    const [input, setInput] = useState<string>('');
    const [image, setImage] = useState<string | null>(null);

    // We need a Ref to the file element so we can capture events from the DOM
    // when it is set. This allows is to capture the image data when a file is
    // chosen and render it as a preview.
    const ref               = useRef<HTMLInputElement>(null);

    // TODO: Extract Into Helper
    const suggestions: string[] = props.images.reduce((all: string[], image) => {
        return [...all, ...image.tags];
    }, []);

    // Do Tag Completion
    const suggestionWord = suggestions.find((tag: string) => {
        const words = input.split(' ');
        const word  = words[words.length - 1];
        return tag.startsWith(word);
    });

    const suggestion = input !== ''
        ? input.split(' ').slice(0, -1).join(' ') + ' ' + (suggestionWord || '')
        : '';

    // Create Event Handlers
    const onTagsChange = (e: React.ChangeEvent<HTMLInputElement>) =>
        setInput(e.target.value);

    const onTagsKeyPress = (e: React.KeyboardEvent<HTMLInputElement>) => {
        if (e.key === 'Enter') {
            const merged = [...tags, ...input.toLowerCase().trim().split(' ')];
            const unique = new Set(merged);
            const sorted = Array.from(unique).sort();
            setTags(sorted);
            setInput('');
        }

        if (e.key === ' ' && suggestion) {
            setInput(suggestion.trim());
        }
    };

    // Handle Image Upload
    const onImageUpload = () => {
        if (ref.current && ref.current.files) {
            const data = new FormData();
            data.append('image', ref.current.files[0]);
            tags.map(tag => {
                data.append('tag', tag);
                console.log('Tag Added: ' + tag);
                return null;
            });
            uploadImage(data).then(() => {
                props.history.push('/');
            });
        }
    }

    // Render Time!
    return (
        <div className="Page">
            <NavigationBar links={headerLinks} username={props.username} />

            <div className={styles.Root}>
                <div className={styles.Tags}>
                    <Button
                        icon="upload"
                        disabled={!image}
                        onClick={onImageUpload}
                    >
                        Upload
                    </Button>

                    <TextInput
                        value={input}
                        suggestion={suggestion && suggestion.trim()}
                        onChange={onTagsChange}
                        placeholder="Enter Tags Here"
                        onKeyPress={onTagsKeyPress}
                    />

                    <div className={styles.TagList}>
                        {
                            tags.map((tag, k) =>
                                <Attribute key={k} icon="tag" name={tag} value="" />
                            )
                        }
                    </div>
                </div>

                <div className={styles.Uploader}>
                    <ImageInput
                        ref={ref}
                        onClick={() => ref.current && ref.current.click()}
                        onChange={setImage} />
                </div>
            </div>
        </div>
    );
}

const mapState = (state: State) => ({
    images:   getImages(state.images),
    username: state.user.username
});

export default connect(mapState)(Image);
